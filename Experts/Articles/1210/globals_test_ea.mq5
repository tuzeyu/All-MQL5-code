//+------------------------------------------------------------------+
//|                                              Globals_test_EA.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
#define GVARS_LIST_SIZE 6
//--- include
#include "CGlobalVarList.mqh"

//--- globals
CGlobalVarList gvarList;
//--- global variables: names
string gVar_names[6]=
  {
   "gvarOpen_start","gvarOpen_finish",
   "gvarClose_start","gvarClose_finish",
   "gvarTrail_start","gvarTrail_finish"
  };
//--- test
bool gToLog=false;
string curr_module="Модуль: ";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- fill the gvarList list with objects of the CGlobalVar type
   for(int idx=0;idx<GVARS_LIST_SIZE;idx++)
     {
      ResetLastError();
      CGlobalVar *ptr_gVar=new CGlobalVar;
      //---
      if(CheckPointer(ptr_gVar)==POINTER_DYNAMIC)
        {
         ResetLastError();
         //--- try to add
         if(gvarList.Add(ptr_gVar)>-1)
            continue;
         //---  
         PrintFormat("Failed to add a new gvar: %d",_LastError);
         return INIT_FAILED;
        }
      //---  
      PrintFormat("Failed to create a new gvar: %d",_LastError);
      return INIT_FAILED;
     }
//--- create\check global variables
   for(int idx=0;idx<GVARS_LIST_SIZE;idx++)
     {
      CGlobalVar *ptr_gVar=gvarList.GetNodeAtIndex(idx);
      if(ptr_gVar!=NULL)
        {
         //--- attempt to create gvar for the set module 
         if(!ptr_gVar.Create(gVar_names[idx]))
            //--- attempt to check for the existence of gvar
            if(ptr_gVar.IsGlobalVar(gVar_names[idx]))
              {
               double val=0.0;
               val=ptr_gVar.GetValue(val);
               if(val==1.)
                 {
                  string module_name=StringSubstr(gVar_names[idx],4);
                  Print("Non-zero value for: <<"+module_name+">>");
                 }
              }
        }
     }

//---
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main();
  }
//+------------------------------------------------------------------+
//| Main module                                                      |
//+------------------------------------------------------------------+
void Main(void)
  {
//--- set flags for all modules
   for(int idx=0;idx<GVARS_LIST_SIZE;idx++)
      SetFlag(idx,false);

//--- Check the trade possibility and connectivity
//--- permission to trade
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      //--- connection to the trading server
      if(TerminalInfoInteger(TERMINAL_CONNECTED))
         //--- permission to trade for the launched EA
         if(MQLInfoInteger(MQL_TRADE_ALLOWED))
           {
            //--- 1) opening module
            Open();
            //--- 2) closing module
            Close();
            //--- 3) Trailing Stop module
            Trail();
           }
  }
//+------------------------------------------------------------------+
//| Open module                                                      |
//+------------------------------------------------------------------+
void Open(void)
  {
   Comment(curr_module+__FUNCTION__);
//---
   if(!IsStopped())
     {
      //--- clear the module start flag
      SetFlag(0,true);

      //--- assume that the module operates for approximately 2 s
        {
         Sleep(2000);
        }
      //--- clear the module finish flag
      SetFlag(1,true);
     }
  }
//+------------------------------------------------------------------+
//| Close module                                                     |
//+------------------------------------------------------------------+
void Close(void)
  {
   Comment(curr_module+__FUNCTION__);
//---
   if(!IsStopped())
     {
      //--- clear the module start flag
      SetFlag(2,true);
      //--- assume that the module operates for approximately 1.5 s
        {
         Sleep(1500);
        }
      //--- clear the module finish flag
      SetFlag(3,true);
     }
  }
//+------------------------------------------------------------------+
//| Trailing module                                                  |
//+------------------------------------------------------------------+
void Trail(void)
  {
   Comment(curr_module+__FUNCTION__);
//---
   if(!IsStopped())
     {
      //--- clear the module start flag
      SetFlag(4,true);
      //--- допустим, модуль работает около 0.75 сек
        {
         Sleep(750);
        }
      //--- clear the module finish flag
      SetFlag(5,true);
     }
  }
//+------------------------------------------------------------------+
//| Set/clear the set module flag                                    |
//+------------------------------------------------------------------+
void SetFlag(const int _idx,const bool _to_reset)
  {
   string module_name=StringSubstr(gVar_names[_idx],4);

//--- forced termination check 
   if(!IsStopped())
     {
      //--- clear the module start flag
      CGlobalVar *ptr_gVar=gvarList.GetNodeAtIndex(_idx);
      if(ptr_gVar!=NULL)
         //--- attempt to check for the existence of gvar
         if(ptr_gVar.IsGlobalVar(gVar_names[_idx]))
           {
            double val=1.0;
            if(_to_reset)
               val=0.0;
            if(!ptr_gVar.Value(val))
               Print("Failed to set the flag for: <<"+module_name+">>");
           }
     }
   else
      Print("Program forced to terminate before execution: <<"+module_name+">>");
  }
//+------------------------------------------------------------------+
