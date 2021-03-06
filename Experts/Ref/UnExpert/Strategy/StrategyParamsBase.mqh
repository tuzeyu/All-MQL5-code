//+------------------------------------------------------------------+
//|                                           StrategyParamsBase.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"

#include "Logs.mqh"
#include "XML\XMLBase.mqh"
//+------------------------------------------------------------------+
//| The class contains basic parameters of any CStrategy.            |
//| Parameters are loaded from the passed XML attribute <Strategy>   |
//+------------------------------------------------------------------+
class CParamsBase
  {
private:
   bool              m_is_valid;       // The flag shows if all the required parameters of the strategy are properly set.
   uint              m_magic;          // The magic number of the strategy
   string            m_name;           // The name of the strategy
   string            m_symbol;         // The symbol of the strategy
   ENUM_TIMEFRAMES   m_timeframe;      // The timeframe of the strategy
   CLog*             Log;              // Logging
   ENUM_TIMEFRAMES   StringToTimeframe(string stf);
public:
                     CParamsBase(CXmlElement *xmlStrategy);
   bool              IsValid(void);
   bool              CheckParams(void);
   uint              Magic(void);
   string            Name(void);
   string            Symbol(void);
   ENUM_TIMEFRAMES   Timeframe(void);
  };
//+------------------------------------------------------------------+
//| Creates a class of basic parameters of the strategy from special |
//| XML element.                                                     |
//+------------------------------------------------------------------+
CParamsBase::CParamsBase(CXmlElement *xmlStrategy) : m_is_valid(false),
                                                     m_magic(0),
                                                     m_name(""),
                                                     m_symbol(""),
                                                     m_timeframe(PERIOD_CURRENT)
  {
   Log=CLog::GetLog();
   for(int i=0; i<xmlStrategy.GetAttributeCount(); i++)
     {
      CXmlAttribute *attr=xmlStrategy.GetAttribute(i);
      string name=attr.GetName();
      if(name=="Name")
         m_name=attr.GetValue();
      else if(name== "Symbol")
         m_symbol = attr.GetValue();
      else if(name== "Magic")
         m_magic=(uint)attr.GetValue();
      else if(name=="Timeframe")
         m_timeframe=StringToTimeframe(attr.GetValue());
     }
   CheckParams();
  }
//+------------------------------------------------------------------+
//| Returns true if all parameters are loaded correctly.             |
//| Otherwise it returns false.                                      |
//+------------------------------------------------------------------+
bool CParamsBase::IsValid(void)
  {
   return m_is_valid;
  }
//+------------------------------------------------------------------+
//| Returns the magic number of the EA.                              |
//+------------------------------------------------------------------+
uint CParamsBase::Magic(void)
  {
   return m_magic;
  }
//+------------------------------------------------------------------+
//| Returns the EA's name.                                           |
//+------------------------------------------------------------------+
string CParamsBase::Name(void)
  {
   return m_name;
  }
//+------------------------------------------------------------------+
//| Returns the EA's working symbol.                                 |
//+------------------------------------------------------------------+
string CParamsBase::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Returns the EA's working timeframe.                              |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CParamsBase::Timeframe(void)
  {
   return m_timeframe;
  }
//+------------------------------------------------------------------+
//| Returns true of all parameters are set correctly.                |
//| Otherwise returns false otherwise, as well as displays           |
//| a warning message about what parameters are                      |
//| set incorrectly.                                                 |
//+------------------------------------------------------------------+
bool CParamsBase::CheckParams(void)
  {
   m_is_valid= true;
   if(m_name == "")
     {
      string text="Missing required XML attribute: 'Name'. Check XML strategy file";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      Log.AddMessage(msg);
      m_is_valid=false;
     }
   if(m_magic==0)
     {
      string text="Missing required XML attribute: 'Magic'. Check XML strategy"+m_name+" file";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      Log.AddMessage(msg);
      m_is_valid=false;
     }
   if(m_symbol=="")
     {
      string text="Missing required XML attribute: 'Symbol'. Check XML strategy"+m_name+" file";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      Log.AddMessage(msg);
      m_is_valid=false;
     }
   if(m_timeframe==PERIOD_CURRENT)
     {
      string text="Missing required XML attribute: 'Timeframe'. Check XML strategy"+m_name+" file";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      Log.AddMessage(msg);
      m_is_valid=false;
     }
   return m_is_valid;
  }
//+------------------------------------------------------------------+
//| Converts string of ENUM_TIMEFRAMES type to timeframe             |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CParamsBase::StringToTimeframe(string stf)
  {
   if(stf=="PERIOD_M1")
      return PERIOD_M1;
   else if(stf=="PERIOD_M2")
      return PERIOD_M2;
   else if(stf=="PERIOD_M3")
      return PERIOD_M3;
   else if(stf=="PERIOD_M4")
      return PERIOD_M4;
   else if(stf=="PERIOD_M5")
      return PERIOD_M5;
   else if(stf=="PERIOD_M6")
      return PERIOD_M6;
   else if(stf=="PERIOD_M10")
      return PERIOD_M10;
   else if(stf=="PERIOD_M12")
      return PERIOD_M12;
   else if(stf=="PERIOD_M15")
      return PERIOD_M15;
   else if(stf=="PERIOD_M20")
      return PERIOD_M20;
   else if(stf=="PERIOD_M30")
      return PERIOD_M30;
   else if(stf=="PERIOD_H1")
      return PERIOD_H1;
   else if(stf=="PERIOD_H2")
      return PERIOD_H2;
   else if(stf=="PERIOD_H3")
      return PERIOD_H3;
   else if(stf=="PERIOD_H4")
      return PERIOD_H4;
   else if(stf=="PERIOD_H6")
      return PERIOD_H6;
   else if(stf=="PERIOD_H8")
      return PERIOD_H8;
   else if(stf=="PERIOD_H12")
      return PERIOD_H12;
   else if(stf=="PERIOD_D1")
      return PERIOD_D1;
   else if(stf=="PERIOD_W1")
      return PERIOD_W1;
   else if(stf=="PERIOD_MN1")
      return PERIOD_MN1;
   return PERIOD_CURRENT;
  }
//+------------------------------------------------------------------+
