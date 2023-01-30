// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

/// The list of possible cameras that are on the rover.
enum MarsRoverCameras {
  /// Front Hazard Avoidance Camera
  fhaz,

  /// Front Hazard Avoidance Camera - Left
  fhazLeft,

  /// Front Hazard Avoidance Camera - Right
  fhazRight,

  /// Rear Hazard Avoidance Camera
  rhaz,

  /// Rear Hazard Avoidance Camera - Left
  rhazLeft,

  /// Rear Hazard Avoidance Camera - Right
  rhazRight,

  /// Mast Camera
  mast,

  /// Mast Camera Zoom - Left
  mczLeft,

  /// Mast Camera Zoom - Right
  mczRight,

  /// Chemistry and Camera Complex
  chemcam,

  /// Mars Hand Lens Imager
  mahli,

  /// Mars Descent Imager
  mardi,

  /// Navigation Camera
  navcam,

  /// Navigation Camera - Left
  navcamLeft,

  /// Navigation Camera - Right
  navcamRight,

  /// Panoramic Camera
  pancam,

  /// Miniature Thermal Emission Spectrometer (Mini-TES)
  minites,

  /// SHERLOC WATSON Camera
  sherlocWatson,

  /// SuperCam Remote Micro Imager
  supercamRmi,

  /// MEDA Skycam
  skycam,

  /// Unknown camera
  unknown,
}

/// Provides a utility class for the cameras.
class MarsRoverCamerasUtil {
  static const String _keyFhaz = "FHAZ";
  static const String _keyFhazLeft = "FRONT_HAZCAM_LEFT_A";
  static const String _keyFhazRight = "FRONT_HAZCAM_RIGHT_A";
  static const String _keyRhaz = "RHAZ";
  static const String _keyRhazLeft = "REAR_HAZCAM_LEFT";
  static const String _keyRhazRight = "REAR_HAZCAM_RIGHT";
  static const String _keyMast = "MAST";
  static const String _keyMczLeft = "MCZ_LEFT";
  static const String _keyMczRight = "MCZ_RIGHT";
  static const String _keyChemcam = "CHEMCAM";
  static const String _keyMahli = "MAHLI";
  static const String _keyMardi = "MARDI";
  static const String _keyNavcam = "NAVCAM";
  static const String _keyNavcamLeft = "NAVCAM_LEFT";
  static const String _keyNavcamRight = "NAVCAM_RIGHT";
  static const String _keyPancam = "PANCAM";
  static const String _keyMinites = "MINITES";
  static const String _keySherlockWatson = "SHERLOC_WATSON";
  static const String _keySupercamRmi = "SUPERCAM_RMI";
  static const String _keySkycam = "SKYCAM";
  static const String _keyUnknown = "UNKNOWN";

  /// Converts from the string key to the camera enum.
  static MarsRoverCameras fromStringKey(String key) {
    switch (key) {
      case _keyFhaz:
        return MarsRoverCameras.fhaz;
      case _keyFhazLeft:
        return MarsRoverCameras.fhazLeft;
      case _keyFhazRight:
        return MarsRoverCameras.fhazRight;
      case _keyRhaz:
        return MarsRoverCameras.rhaz;
      case _keyRhazLeft:
        return MarsRoverCameras.rhazLeft;
      case _keyRhazRight:
        return MarsRoverCameras.rhazRight;
      case _keyMast:
        return MarsRoverCameras.mast;
      case _keyMczLeft:
        return MarsRoverCameras.mczLeft;
      case _keyMczRight:
        return MarsRoverCameras.mczRight;
      case _keyChemcam:
        return MarsRoverCameras.chemcam;
      case _keyMahli:
        return MarsRoverCameras.mahli;
      case _keyMardi:
        return MarsRoverCameras.mardi;
      case _keyNavcam:
        return MarsRoverCameras.navcam;
      case _keyNavcamLeft:
        return MarsRoverCameras.navcamLeft;
      case _keyNavcamRight:
        return MarsRoverCameras.navcamRight;
      case _keyPancam:
        return MarsRoverCameras.pancam;
      case _keyMinites:
        return MarsRoverCameras.minites;
      case _keySherlockWatson:
        return MarsRoverCameras.sherlocWatson;
      case _keySupercamRmi:
        return MarsRoverCameras.supercamRmi;
      case _keySkycam:
        return MarsRoverCameras.skycam;
      default:
        return MarsRoverCameras.unknown;
    }
  }

  /// Converts from the camera enum to the string key.
  static String toStringKey(MarsRoverCameras camera) {
    switch (camera) {
      case MarsRoverCameras.fhaz:
        return _keyFhaz;
      case MarsRoverCameras.fhazLeft:
        return _keyFhazLeft;
      case MarsRoverCameras.fhazRight:
        return _keyFhazRight;
      case MarsRoverCameras.rhaz:
        return _keyRhaz;
      case MarsRoverCameras.rhazLeft:
        return _keyRhazLeft;
      case MarsRoverCameras.rhazRight:
        return _keyRhazRight;
      case MarsRoverCameras.mast:
        return _keyMast;
      case MarsRoverCameras.mczLeft:
        return _keyMczLeft;
      case MarsRoverCameras.mczRight:
        return _keyMczRight;
      case MarsRoverCameras.chemcam:
        return _keyChemcam;
      case MarsRoverCameras.mahli:
        return _keyMahli;
      case MarsRoverCameras.mardi:
        return _keyMardi;
      case MarsRoverCameras.navcam:
        return _keyNavcam;
      case MarsRoverCameras.navcamLeft:
        return _keyNavcamLeft;
      case MarsRoverCameras.navcamRight:
        return _keyNavcamRight;
      case MarsRoverCameras.pancam:
        return _keyPancam;
      case MarsRoverCameras.minites:
        return _keyMinites;
      case MarsRoverCameras.sherlocWatson:
        return _keySherlockWatson;
      case MarsRoverCameras.supercamRmi:
        return _keySupercamRmi;
      case MarsRoverCameras.skycam:
        return _keySkycam;
      case MarsRoverCameras.unknown:
        return _keyUnknown;
    }
  }
}
