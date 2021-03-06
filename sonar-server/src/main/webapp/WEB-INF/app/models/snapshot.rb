#
# Sonar, entreprise quality control tool.
# Copyright (C) 2008-2011 SonarSource
# mailto:contact AT sonarsource DOT com
#
# Sonar is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Sonar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Sonar; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
#
class Snapshot < ActiveRecord::Base
  include Resourceable
  acts_as_tree :foreign_key => 'parent_snapshot_id'

  belongs_to :project
  belongs_to :root_project, :class_name => 'Project', :foreign_key => 'root_project_id'
  belongs_to :parent_snapshot, :class_name => 'Snapshot', :foreign_key => 'parent_snapshot_id'
  belongs_to :root_snapshot, :class_name => 'Snapshot', :foreign_key => 'root_snapshot_id'
  belongs_to :characteristic

  has_many :measures, :class_name => 'ProjectMeasure', :conditions => 'rule_id IS NULL AND rule_priority IS NULL AND characteristic_id IS NULL'
  has_many :rulemeasures, :class_name => 'ProjectMeasure', :conditions => '(rule_id IS NOT NULL OR rule_priority IS NOT NULL) AND characteristic_id IS NULL'
  has_many :characteristic_measures, :class_name => 'ProjectMeasure', :conditions => 'rule_id IS NULL AND rule_priority IS NULL AND characteristic_id IS NOT NULL'
  
  has_many :events, :dependent => :destroy, :order => 'event_date DESC'
  has_one :source, :class_name => 'SnapshotSource', :dependent => :destroy
  has_many :violations, :class_name => 'RuleFailure'

  has_many :async_measure_snapshots
  has_many :async_measures, :through => :async_measure_snapshots


  STATUS_UNPROCESSED = 'U'
  STATUS_PROCESSED = 'P'

  def self.last_enabled_projects
    Snapshot.find(:all, 
      :include => 'project',
      :conditions => ['snapshots.islast=? and projects.scope=? and projects.qualifier=? and snapshots.scope=? and snapshots.qualifier=?',
        true, Project::SCOPE_SET, Project::QUALIFIER_PROJECT, Project::SCOPE_SET, Project::QUALIFIER_PROJECT])
  end
  
  def self.for_timemachine_matrix(resource)
    # http://jira.codehaus.org/browse/SONAR-1850
    # Conditions on scope and qualifier are required to exclude library snapshots.
    # Use-case :
    #   1. project A 2.0 is analyzed -> new snapshot A with qualifier TRK
    #   2. project B, which depends on A 1.0, is analyzed -> new snapshot A 1.0 with qualifier LIB.
    #   3. project A has 2 snapshots : the first one with qualifier=TRK has measures, the second one with qualifier LIB has no measures. Its version must not be used in time machine
    # That's why the 2 following SQL requests check the qualifiers (and optionally scopes, just to be sure)
    snapshots=Snapshot.find(:all, :conditions => ["snapshots.project_id=? AND events.snapshot_id=snapshots.id AND snapshots.status=? AND snapshots.scope=? AND snapshots.qualifier=?", resource.id, STATUS_PROCESSED, resource.scope, resource.qualifier],
       :include => 'events',
       :order => 'snapshots.created_at ASC')

    snapshots<<resource.last_snapshot if snapshots.empty?
    
    snapshots=snapshots[-5,5] if snapshots.size>=5

    snapshots.insert(0, Snapshot.find(:first,
         :conditions => ["project_id=? AND status=? AND scope=? AND qualifier=?", resource.id, STATUS_PROCESSED, resource.scope, resource.qualifier],
         :include => 'project', :order => 'snapshots.created_at ASC', :limit => 1))

    snapshots.compact.uniq
  end

  def last?
    islast
  end

  def root_snapshot
    @root_snapshot ||=
      (root_snapshot_id ? Snapshot.find(root_snapshot_id) : self)
  end
  
  def project_snapshot
    @project_snapshot ||=
    begin
      if scope==Project::SCOPE_SET
        self
      elsif parent_snapshot_id
        parent_snapshot.project_snapshot
      else
        nil
      end
    end
  end

  def root?
    parent_snapshot_id.nil?
  end

  def all_measures
    measures + async_measures
  end
  
  def descendants
    children.map(&:descendants).flatten + children
  end

  def user_events
    categories=EventCategory.categories(true)
    category_names=categories.map{|cat| cat.name}
    Event.find(:all, :conditions => ["snapshot_id=? AND category IS NOT NULL", id], :order => 'event_date desc').select do |event|
      category_names.include?(event.category)
    end
  end

  def event(category)
    result=events.select{|e| e.category==category}
    if result.empty?
      nil
    else
      result.first
    end
  end

  def metrics
    if @metrics.nil?
      @metrics = []
      measures_hash.each_key do |metric_id|
        @metrics << Metric::by_id(metric_id)
      end
      @metrics.uniq!
    end
    @metrics
  end

  def measure(metric)
    unless metric.is_a? Metric
      metric=Metric.by_key(metric)
    end
    metric ? measures_hash[metric.id] : nil
  end

  def characteristic_measure(metric, characteristic)
    characteristic_measures.each do |m|
      return m if m.metric_id==metric.id && m.characteristic==characteristic
    end
    nil
  end

  def f_measure(metric)
    m=measure(metric)
    m ? m.formatted_value : nil
  end

  def rule_measures(metric=nil, rule_priority=nil)
    rulemeasures.select do |m|
      m.rule_id && (metric ? m.metric_id==metric.id : true) && (rule_priority ? m.rule_priority==rule_priority : true)
    end
  end
  
  def rule_priority_measures(metric_key)
    rulemeasures.select do |measure|
      measure.rule_id.nil? && measure.rule_priority && measure.metric && measure.metric.key==metric_key
    end
  end

  def self.snapshot_by_date(resource_id, date)
    if resource_id && date
      Snapshot.find(:first, :conditions => ['created_at>=? and created_at<? and project_id=?', date.beginning_of_day, date.end_of_day, resource_id], :order => 'created_at desc')
    else
      nil
    end
  end

  def resource
    project
  end

  def periods?
    (period1_mode || period2_mode || period3_mode || period4_mode || period5_mode) != nil
  end

  def resource_id_for_authorization
    root_project_id || project_id
  end

  def path_name
    result=''
    if root_snapshot_id && root_snapshot_id!=id
      result += root_snapshot.project.long_name
      result += ' &raquo; '
      if root_snapshot.depth<self.depth-2
        result += ' ... &raquo; '
      end
      if parent_snapshot_id && root_snapshot_id!=parent_snapshot_id
        result += "#{parent_snapshot.project.long_name} &raquo; "
      end
    end
    result += project.long_name
    result
  end

  def period_mode(period_index)
    project_snapshot.send "period#{period_index}_mode"
  end

  def period_param(period_index)
    project_snapshot.send "period#{period_index}_param"
  end

  def period_datetime(period_index)
    project_snapshot.send "period#{period_index}_date"
  end

  private

  def measures_hash
    @measures_hash ||=
      begin
        hash = {}
        all_measures.each do |measure|
          hash[measure.metric_id]=measure
        end
        hash
      end
  end

end
