
load helpers

@test "'elm-land customize' fails without an argument" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize
  expectToFail
  expectOutputContains "Missing a required argument"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize fart' fails with an invalid argument" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize fart
  expectToFail
  expectOutputContains "Here are the available options"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize shared' moves Shared file into src folder" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize shared
  expectToPass
  expectOutputContains "File is now customizable at ./src/Shared.elm"

  expectFileExists "src/Shared.elm"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "cleanup" {
  cleanupTmpFolder
}