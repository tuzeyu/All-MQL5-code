//+------------------------------------------------------------------+
//|                                                 PriceChannel.mqh |
//|                                   Copyright 2015, Victor Vityuk. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Victor Vityuk."
#property link      "http://www.mql5.com"
#include <Strategy\Message.mqh>
#include <Strategy\Logs.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CIndPriceChannel
  {
private:
   int               m_pc_handle;         // Indicator handle
   ENUM_TIMEFRAMES   m_timeframe;         // Timeframe
   int               m_pc_period;         // Period
   string            m_symbol;            // Symbol
   CLog*             m_log;               // Logging
   void              Init(void);

public:
                     CIndPriceChannel(void);

/*Params*/
   void              Timeframe(ENUM_TIMEFRAMES timeframe);
   void              PC_Period(int pc_period);
   void              Symbol(string symbol);

   ENUM_TIMEFRAMES   Timeframe(void);
   int               PC_Period(void);
   string            Symbol(void);

/*Out values*/
   double            OutValueUp(int index);
   double            OutValueDown(int index);
  };
//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CIndPriceChannel::CIndPriceChannel(void) : m_pc_handle(INVALID_HANDLE),
                                           m_timeframe(PERIOD_CURRENT),
                                           m_pc_period(50)
  {
   m_log=CLog::GetLog();
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
CIndPriceChannel::Init(void)
  {
   if(m_pc_handle!=INVALID_HANDLE)
     {
      bool res=IndicatorRelease(m_pc_handle);
      if(!res)
        {
         string text="Realise PC indicator failed. Error ID: "+(string)GetLastError();
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         m_log.AddMessage(msg);
        }
     }
   m_pc_handle=iCustom(m_symbol,m_timeframe,"Examples\\Price_Channel",m_pc_period);

   if(m_pc_handle==INVALID_HANDLE)
     {
      string params="(Period:"+(string)m_pc_period+")";
      string text="Create PC indicator failed"+params+". Error ID: "+(string)GetLastError();
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      m_log.AddMessage(msg);
     }
  }
//+------------------------------------------------------------------+
//| Setting timeframe.                                               |
//+------------------------------------------------------------------+
void CIndPriceChannel::Timeframe(ENUM_TIMEFRAMES tf)
  {
   m_timeframe=tf;
   if(m_pc_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the current timeframe                                    |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CIndPriceChannel::Timeframe(void)
  {
   return m_timeframe;
  }
//+------------------------------------------------------------------+
//| Sets the Moving Average averaging period.                        |
//+------------------------------------------------------------------+
void CIndPriceChannel::PC_Period(int pc_period)
  {
   m_pc_period=pc_period;
   if(m_pc_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the current averaging period of Moving Average.          |
//+------------------------------------------------------------------+
int CIndPriceChannel::PC_Period(void)
  {
   return m_pc_period;
  }
//+------------------------------------------------------------------+
//| Sets the symbol to calculate the indicator for                   |
//+------------------------------------------------------------------+
void CIndPriceChannel::Symbol(string symbol)
  {
   m_symbol=symbol;
   if(m_pc_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the symbol the indicator is calculated for               |
//+------------------------------------------------------------------+
string CIndPriceChannel::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CIndPriceChannel::OutValueUp(int index)
  {
   if(m_pc_handle==INVALID_HANDLE)
      Init();
   double values[];
   if(CopyBuffer(m_pc_handle,0,index,1,values))
      return values[0];
   return EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CIndPriceChannel::OutValueDown(int index)
  {
   if(m_pc_handle==INVALID_HANDLE)
      Init();
   double values[];
   if(CopyBuffer(m_pc_handle,1,index,1,values))
      return values[0];
   return EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
