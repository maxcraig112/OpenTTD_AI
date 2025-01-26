class TestAI extends AIInfo
{
  function GetAuthor()      { return "Maximilian"; }
  function GetName()        { return "TestAI"; }
  function GetDescription() { return "An example AI by following the tutorial at http://wiki.openttd.org/"; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "2025-1-26"; }
  function CreateInstance() { return "TestAI"; }
  function GetShortName()   { return "Test"; }

  function GetSettings()
  {
    AddSetting({name = "bool_setting",
                description = "a bool setting, default off",
                easy_value = 0,
                medium_value = 0,
                hard_value = 0,
                custom_value = 0,
                flags = AICONFIG_BOOLEAN});

    AddSetting({name = "bool2_setting",
               description = "a bool setting, default on",
               easy_value = 1,
               medium_value = 1,
               hard_value = 1,
               custom_value = 1,
               flags = AICONFIG_BOOLEAN});

    AddSetting({name = "int_setting",
                description = "an int setting",
                easy_value = 30,
                medium_value = 20,
                hard_value = 10,
                custom_value = 20,
                flags = 0,
                min_value = 1,
                max_value = 100});
  }
}

RegisterAI(TestAI());