/*
 * Sonar, open source software quality management tool.
 * Copyright (C) 2008-2011 SonarSource
 * mailto:contact AT sonarsource DOT com
 *
 * Sonar is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * Sonar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with Sonar; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
 */
package org.sonar.api.batch.events;

import org.sonar.api.batch.Sensor;

import java.util.List;

/**
 * @since 2.8
 */
public interface SensorsPhaseHandler extends EventHandler {

  /**
   * This interface is not intended to be implemented by clients.
   */
  public interface SensorsPhaseEvent {

    /**
     * @return list of Sensors in the order of execution
     */
    List<Sensor> getSensors();

    boolean isStart();

    boolean isEnd();

  }

  /**
   * Called before and after execution of all {@link Sensor}s.
   */
  void onSensorsPhase(SensorsPhaseEvent event);

}
