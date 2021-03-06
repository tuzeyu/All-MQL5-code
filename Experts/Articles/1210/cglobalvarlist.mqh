//+------------------------------------------------------------------+
//|                                               CGlobalVarList.mqh |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
//---
#include <Arrays\List.mqh>
#include "CGlobalVar.mqh"
//+------------------------------------------------------------------+
//| Enumeration for gvars type                                       |
//+------------------------------------------------------------------+
enum ENUM_GVARS_TYPE
  {
   GVARS_TYPE_ALL=-1,  // all global
   GVARS_TYPE_FULL=0,  // only full
   GVARS_TYPE_TEMP=1,  // only temporary
  };
//+------------------------------------------------------------------+
//| Class CGlobalVarList                                             |
//+------------------------------------------------------------------+
class CGlobalVarList : public CList
  {
   //--- === Data members === --- 
private:
   ENUM_GVARS_TYPE   m_gvars_type;

   //--- === Methods === --- 
public:
   //--- constructor/destructor
   void              CGlobalVarList(void);
   void             ~CGlobalVarList(void){};
   //--- load/unload
   bool              LoadCurrentGlobals(void);
   bool              KillCurrentGlobals(void);
   //--- working with files
   virtual bool      Save(const int _file_ha);
   virtual bool      Load(const int _file_ha);
   //--- service
   void              Print(const int _digs);
   void              SetGvarType(const ENUM_GVARS_TYPE _gvar_type);
   //---
private:
   bool              CheckGlobalVar(const string _var_name);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CGlobalVarList::CGlobalVarList(void)
  {
   this.m_gvars_type=GVARS_TYPE_ALL;
  }
//+------------------------------------------------------------------+
//| Load current global vars                                         |
//+------------------------------------------------------------------+
bool CGlobalVarList::LoadCurrentGlobals(void)
  {
   ENUM_GVARS_TYPE curr_gvar_type=this.m_gvars_type;
   int gvars_cnt=GlobalVariablesTotal();
//---
   for(int idx=0;idx<gvars_cnt;idx++)
     {
      string gvar_name=GlobalVariableName(idx);
      if(this.CheckGlobalVar(gvar_name))
         continue;

      //--- gvar properties
      double gvar_val=GlobalVariableGet(gvar_name);
      datetime gvar_time=GlobalVariableTime(gvar_name);
      CGlobalVar *ptr_gvar=new CGlobalVar(gvar_name,gvar_val,gvar_time);
      //--- control gvar type 
      if(CheckPointer(ptr_gvar)==POINTER_DYNAMIC)
        {
         //--- check gvar type
         if(curr_gvar_type>GVARS_TYPE_ALL)
           {
            bool is_temp=ptr_gvar.IsTemporary();
            //--- only full-fledged
            if(curr_gvar_type==GVARS_TYPE_FULL)
              {if(is_temp)continue;}
            //--- only temporary
            else if(curr_gvar_type==GVARS_TYPE_TEMP)
              {if(!is_temp)continue;}
           }
         //--- try to add
         if(this.Add(ptr_gvar)>-1)
            continue;
        }
      //---
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Killing the global vars                                          |
//+------------------------------------------------------------------+
bool CGlobalVarList::KillCurrentGlobals(void)
  {
   ENUM_GVARS_TYPE curr_gvar_type=this.m_gvars_type;
   int gvar_num=this.Total();
//---
   for(int idx=gvar_num-1;idx>=0;idx--)
     {
      CGlobalVar *ptr_gvar=this.GetNodeAtIndex(idx);
      if(ptr_gvar!=NULL)
        {
         //--- check gvar type
         if(curr_gvar_type>GVARS_TYPE_ALL)
           {
            bool is_temp=ptr_gvar.IsTemporary();
            //--- only full-fledged
            if(curr_gvar_type==GVARS_TYPE_FULL)
              {if(is_temp)continue;}
            //--- only temporary
            else if(curr_gvar_type==GVARS_TYPE_TEMP)
              {if(!is_temp)continue;}
           }
         string curr_gvar_name=ptr_gvar.Name();
         //--- try to delete
         if(GlobalVariableDel(curr_gvar_name))
            if(this.Delete(idx))
               continue;
         //---
         return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Saving                                                           |
//+------------------------------------------------------------------+
bool CGlobalVarList::Save(const int _file_ha)
  {
   if(_file_ha==INVALID_HANDLE)
      return false;
//---
   int gvar_num=this.Total();
//---
   if(gvar_num>0)
     {
      //--- columns
      FileWrite(_file_ha,"Name","Value","Creation time","Last call time");
      //---
      for(int idx=gvar_num-1;idx>=0;idx--)
        {
         CGlobalVar *ptr_gvar=this.GetNodeAtIndex(idx);
         if(ptr_gvar!=NULL)
           {
            if(!ptr_gvar.IsTemporary())
              {
               //--- gvar properties
               string curr_gvar_name=ptr_gvar.Name();
               double curr_gvar_val=GlobalVariableGet(curr_gvar_name);
               datetime curr_gvar_create_time=ptr_gvar.CreateTime();
               datetime curr_gvar_last_time=ptr_gvar.LastTime();
               //--- write
               FileWrite(_file_ha,curr_gvar_name,DoubleToString(curr_gvar_val),
                         TimeToString(curr_gvar_create_time,
                         TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                         TimeToString(curr_gvar_last_time,
                         TIME_DATE|TIME_MINUTES|TIME_SECONDS));
              }
           }
         else
           {
            Print("Failed to get the gvar object!");
            return false;
           }
        }
      //---
      return true;
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Loading                                                          |
//+------------------------------------------------------------------+
bool CGlobalVarList::Load(const int _file_ha)
  {
   if(_file_ha==INVALID_HANDLE || !FileSeek(_file_ha,0,SEEK_SET))
      return false;
//---
   SetGvarType(GVARS_TYPE_FULL);
//--- skip the first string
   while(!FileIsLineEnding(_file_ha))
      FileReadString(_file_ha);

//--- read the data from the file
   while(!FileIsEnding(_file_ha))
     {
      //--- name
      string gvar_name=FileReadString(_file_ha);
      //--- value
      double gvar_val=StringToDouble(FileReadString(_file_ha));
      //--- creation time
      datetime gvar_create_time=StringToTime(FileReadString(_file_ha));
      FileReadString(_file_ha);
      //---
      CGlobalVar *ptr_gvar=new CGlobalVar(gvar_name,gvar_val,gvar_create_time);
      //--- control gvar type 
      if(CheckPointer(ptr_gvar)==POINTER_DYNAMIC)
         //--- try to add
         if(this.Add(ptr_gvar)>-1)
            continue;
      //---
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Print                                                            |
//+------------------------------------------------------------------+
void CGlobalVarList::Print(const int _digs)
  {
   int gvar_num=this.Total();
   Print("\n---===Local list===---");
   PrintFormat("Global variable type: %s",EnumToString(this.m_gvars_type));
   PrintFormat("Total number of global variables: %d",GlobalVariablesTotal());
   PrintFormat("Number of global variables in current list: %d",gvar_num);
//---
   for(int idx=0;idx<gvar_num;idx++)
     {
      CGlobalVar *ptr_gvar=this.GetNodeAtIndex(idx);
      if(ptr_gvar!=NULL)
        {
         string curr_gvar_name=ptr_gvar.Name();
         double val=0.0;
         double curr_gvar_val=ptr_gvar.GetValue(val);
         PrintFormat("Gvar #%d, имя - %s, значение - %0."+IntegerToString(_digs)+
                     "f",idx+1,curr_gvar_name,curr_gvar_val);
        }
     }
  }
//+------------------------------------------------------------------+
//| Set a type for gvars                                             |
//+------------------------------------------------------------------+
void CGlobalVarList::SetGvarType(const ENUM_GVARS_TYPE _gvar_type)
  {
   this.m_gvars_type=_gvar_type;
  }
//+------------------------------------------------------------------+
//| Check the global var by name                                     |
//+------------------------------------------------------------------+
bool CGlobalVarList::CheckGlobalVar(const string _var_name)
  {
   int gvar_num=this.Total();
//---
   for(int idx=0;idx<gvar_num;idx++)
     {
      CGlobalVar *ptr_gvar=this.GetNodeAtIndex(idx);
      if(ptr_gvar!=NULL)
        {
         string curr_gvar_name=ptr_gvar.Name();
         if(!StringCompare(curr_gvar_name,_var_name))
            return true;
        }
     }
//---
   return false;
  }
//--- [EOF]
