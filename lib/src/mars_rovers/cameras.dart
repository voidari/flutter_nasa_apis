// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

/// The list of possible cameras that are on the rover.
enum MarsRoverCameras {
  /// Front Hazard Avoidance Camera
  fhaz,

  /// Rear Hazard Avoidance Camera
  rhaz,

  /// Mast Camera
  mast,

  /// Chemistry and Camera Complex
  chemcam,

  /// Mars Hand Lens Imager
  mahli,

  /// Mars Descent Imager
  mardi,

  /// Navigation Camera
  navcam,

  /// Panoramic Camera
  pancam,

  /// Miniature Thermal Emission Spectrometer (Mini-TES)
  minites,

  /// Unknown camera
  unknown,
}
