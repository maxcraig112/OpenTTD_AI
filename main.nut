require("town.nut");
require("rail.nut");
class TestAI extends AIController
 {
   constructor()
   {
   }
 }


 function TestAI::Start()
 {
   local towns = Towns();
   AILog.Info("TestAI Started.");
   AILog.Info("Map Size: " + AIMap.GetMapSize());

   SetCompanyName();

   //set a legal railtype.

   AICompany.SetLoanAmount(AICompany.GetLoanInterval());
   local types = AIRailTypeList();
   AIRail.SetCurrentRailType(types.Begin());

   //Keep running. If Start() exits, the AI dies.
   while (true) {
      ConnectTwoLargestTowns(towns);
      this.Sleep(100000);
      AILog.Warning("TODO: Add functionality to the AI.");
   }
 }

 function TestAI::Save()
 {
   local table = {};
   //TODO: Add your save data to the table.
   return table;
 }

 function TestAI::Load(version, data)
 {
   AILog.Info(" Loaded");
   //TODO: Add your loading routines.
 }


 function TestAI::SetCompanyName()
 {
   if(!AICompany.SetName("Testing AI")) {
     local i = 2;
     while(!AICompany.SetName("Testing AI #" + i)) {
       i = i + 1;
       if(i > 255) break;
     }
   }
   AICompany.SetPresidentName("P. Resident");
 }


