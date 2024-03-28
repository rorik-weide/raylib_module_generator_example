/*
# Project Configuration

  This file is automatically loaded into { main.jai } as well.
  Some things are extra, because I copied things from my usual setup.
*/

Project_Build_Mode : enum u8 {
  DEBUG :: 0;
  RELEASE;
  SOMETHING_ELSE;
}

PROJECT_NAME            :: "Raylib Module Generator";
PROJECT_BUILD_MODE      :: Project_Build_Mode.DEBUG;
PROJECT_VERSION_MAJOR   :: 0;
PROJECT_VERSION_MINOR   :: 1;

BUILD_OUTPUT_DIRECTORY          :: "bin/";
LOCAL_MODULE_IMPORT_DIRECTORY   :: "local_modules";
