//+------------------------------------------------------------------+
//|                                                   CGlobalVar.mqh |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
//---
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class CGlobalVar                                                 |
//+------------------------------------------------------------------+
class CGlobalVar : public CObject
  {
   //--- === Data members === --- 
private:
   string            m_name;
   double            m_value;
   //---
   datetime          m_create_time;
   datetime          m_last_time;
   //--- flag for temporary var
   bool              m_is_temp;

   //--- === Methods === --- 
public:
   //--- constructor/destructor
   void              CGlobalVar(void);
   void              CGlobalVar(const string _var_name,const double _var_val,
                                const datetime _create_time);
   void             ~CGlobalVar(void){};
   //--- create/delete
   bool              Create(const string _var_name,const double _var_val=0.0,
                            const bool _is_temp=false);
   bool              Delete(void);
   //--- exist
   bool              IsGlobalVar(const string _var_name,bool _to_print=false);

   //--- set methods
   bool              Value(const double _var_val);
   bool              ValueOnCondition(const double _var_new_val,const double _var_check_val);

   //--- get methods
   string            Name(void) const;
   datetime          CreateTime(void) const;
   datetime          LastTime(void);
   template<typename T>
   T                 GetValue(T _type) const;
   bool              IsTemporary(void) const;
   //---
private:
   string            FormName(const string _base_name,const bool _is_temp=false);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CGlobalVar::CGlobalVar(void)
  {
   this.m_name=NULL;
   this.m_create_time=this.m_last_time=0;
   this.m_value=WRONG_VALUE;
   this.m_is_temp=false;
  }
//+------------------------------------------------------------------+
//| Parameterized constructor                                        |
//+------------------------------------------------------------------+
void CGlobalVar::CGlobalVar(const string _var_name,const double _var_val,
                            const datetime _create_time):
                            m_name(_var_name),m_value(_var_val),m_create_time(_create_time)

  {
   this.m_last_time=TimeCurrent();
   this.m_is_temp=this.IsTemporary();
  }
//+------------------------------------------------------------------+
//| Creating                                                         |
//+------------------------------------------------------------------+
bool CGlobalVar::Create(const string _var_name,const double _var_val=0.0,
                        const bool _is_temp=false)
  {
   string curr_var_name=this.FormName(_var_name);

//--- check the existence of a global variable
   if(!GlobalVariableCheck(curr_var_name))
     {
      if(_is_temp)
         //--- create a temporary global variable
         if(!GlobalVariableTemp(curr_var_name))
           {
            Print("Failed to create a temporary global variable!");
            return false;
           }

      datetime creation_time=GlobalVariableSet(curr_var_name,_var_val);
      //--- check the creation time
      if(creation_time>0)
        {
         this.m_create_time=this.m_last_time=creation_time;
         this.m_name=curr_var_name;
         this.m_value=_var_val;
         this.m_is_temp=_is_temp;
         return true;
        }
      else
        {
         Print("Failed to set a new value for the global variable\""+curr_var_name+"\"!");
         //--- in case if it does exist
         if(GlobalVariableCheck(curr_var_name))
            if(!GlobalVariableDel(curr_var_name))
               Alert("Delete the global variable \""+curr_var_name+"\"!");
         return false;
        }
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
bool CGlobalVar::Delete(void)
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
         if(GlobalVariableDel(this.m_name))
            return true;
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Checking the global var existence                                |
//+------------------------------------------------------------------+
bool CGlobalVar::IsGlobalVar(const string _var_name,bool _to_print=false)
  {
   bool is_gvar=false;
   string gvar_name=this.FormName(_var_name);
   is_gvar=GlobalVariableCheck(gvar_name);
//---
   if(is_gvar)
     {
      this.m_name=gvar_name;
      this.m_create_time=this.m_last_time=GlobalVariableTime(gvar_name);
      this.m_value=GlobalVariableGet(gvar_name);
      this.m_is_temp=this.IsTemporary();
      //---
      if(_to_print)
         Print("The gvar \""+_var_name+"\" does exist.");
     }
   else
     {
      if(_to_print)
         Print("The gvar \""+_var_name+"\" doesn't exist.");
     }
//---
   return is_gvar;
  }
//+------------------------------------------------------------------+
//| Setting a new value                                              |
//+------------------------------------------------------------------+
bool CGlobalVar::Value(const double _var_val)
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
        {
         datetime new_date=GlobalVariableSet(this.m_name,_var_val);
         //---
         if(new_date>0)
           {
            this.m_last_time=new_date;
            this.m_value=_var_val;
            return true;
           }
         else
           {
            Print("Failed to set a new value for the global variable\""+this.m_name+"\"!");
            return false;
           }
        }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Setting a new value on condition                                 |
//+------------------------------------------------------------------+
bool CGlobalVar::ValueOnCondition(const double _var_new_val,const double _var_check_val)
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
        {
         if(GlobalVariableSetOnCondition(this.m_name,_var_new_val,_var_check_val))
           {
            this.m_last_time=GlobalVariableTime(this.m_name);
            this.m_value=_var_new_val;
            return true;
           }
         else
           {
            Print("Failed to set a new value for the global variable\""+this.m_name+"\" on condition!");
            return false;
           }
        }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Getting the name                                                 |
//+------------------------------------------------------------------+
string CGlobalVar::Name(void) const
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
         return this.m_name;
//---
   return NULL;
  }
//+------------------------------------------------------------------+
//| Getting the initial time                                         |
//+------------------------------------------------------------------+
datetime CGlobalVar::CreateTime(void) const
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
         return this.m_create_time;
//---
   return 0;
  }
//+------------------------------------------------------------------+
//| Getting the last time                                            |
//+------------------------------------------------------------------+
datetime CGlobalVar::LastTime(void)
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
        {
         this.m_last_time=GlobalVariableTime(this.m_name);
         return this.m_last_time;
        }
//---
   return 0;
  }
//+------------------------------------------------------------------+
//| Template for getting the value                                   |
//+------------------------------------------------------------------+
template<typename T>
T CGlobalVar::GetValue(T _type) const
  {
   if(this.m_name!=NULL)
      if(GlobalVariableCheck(this.m_name))
         return (T)this.m_value;
//---
   return (T)0;
  }
//+------------------------------------------------------------------+
//| Getting the flag for temporary                                   |
//+------------------------------------------------------------------+
bool CGlobalVar::IsTemporary(void) const
  {
   string gvar_name=this.m_name;
//---
   if(gvar_name!=NULL)
     {
      int str_pos=StringFind(gvar_name,"_temp_");
      if(str_pos>-1)
         return true;
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Form the full name for gvar                                      |
//+------------------------------------------------------------------+
string CGlobalVar::FormName(const string _base_name,const bool _is_temp=false)
  {
   string gvar_name=NULL;
//---
   gvar_name=_base_name;
   if(_is_temp)
      gvar_name+="_temp";
   gvar_name+="_prog_"+MQLInfoString(MQL_PROGRAM_NAME);
   string curr_prog_type_str=NULL;
   ENUM_PROGRAM_TYPE curr_prog_type=(ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE);
   curr_prog_type_str=EnumToString(curr_prog_type);
   curr_prog_type_str=StringSubstr(curr_prog_type_str,8,3);
   StringToLower(curr_prog_type_str);
   gvar_name+="_"+curr_prog_type_str;
//---
   return gvar_name;
  }

//--- [EOF]
