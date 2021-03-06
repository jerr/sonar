#
# Sonar, open source software quality management tool.
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
class CreateAlertsTable < ActiveRecord::Migration

  def self.up
    create_table :alerts do |t|
      t.column :profile_id,  :integer
      t.column :metric_id,  :integer
      t.column :operator,   :string, :limit => 3, :null => true
      t.column :value_error,    :string, :limit => 64, :null => true
      t.column :value_warning,  :string, :limit => 64, :null => true
    end

    add_column :project_measures, :alert_status, :string, :limit => 5, :null => true
        
  end

end
