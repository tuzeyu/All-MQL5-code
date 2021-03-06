//+------------------------------------------------------------------+
//|                                                  TimeControl.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"

#define ALL_DAYS_OF_WEEK 7
//+------------------------------------------------------------------+
//| Determines the EA's trading state.                               |
//+------------------------------------------------------------------+
enum ENUM_TRADE_STATE
  {
   TRADE_BUY_AND_SELL,              // Buys and Sells are allowed.
   TRADE_BUY_ONLY,                  // Only buy operations are allowed. Sell operations are not allowed.
   TRADE_SELL_ONLY,                 // Only sell operations are allowed. Buy operations are not allowed.
   TRADE_STOP,                      // Trading is disabled. Close all positions immediately. Do not accept new entry signals.
   TRADE_WAIT,                      // Control over opened positions is lost. New signals are ignored. Useful during the news releases.
   TRADE_NO_NEW_ENTRY               // Entry signals are ignored. Although the opened positions are maintained according to the trading logic. 
  };
//+------------------------------------------------------------------+
//| Module of trading states TradeState                              |
//+------------------------------------------------------------------+
class CTradeState
  {
private:
   ENUM_TRADE_STATE  m_state[60*24*7];  // Mask of trading states
public:
                     CTradeState(void);
                     CTradeState(ENUM_TRADE_STATE default_state);
   ENUM_TRADE_STATE  GetTradeState(void);
   ENUM_TRADE_STATE  GetTradeState(datetime time_current);
   void              SetTradeState(datetime time_begin,datetime time_end,int day_of_week,ENUM_TRADE_STATE state);
  };
//+------------------------------------------------------------------+
//| Default mode is TRADE_BUY_AND_SELL                               |
//+------------------------------------------------------------------+
CTradeState::CTradeState(void)
  {
   ArrayInitialize(m_state,TRADE_BUY_AND_SELL);
  }
//+------------------------------------------------------------------+
//| The default mode is set by the value of default_state            |
//+------------------------------------------------------------------+
CTradeState::CTradeState(ENUM_TRADE_STATE default_state)
  {
   ArrayInitialize(m_state,default_state);
  }
//+------------------------------------------------------------------+
//| Sets the TradeState trading state                                |
//| INPUT:                                                           |
//| time_begin  - beginning of period during which trading state     |
//|               is valid.                                          |
//| time_end    - the time till which the trading state is valid     |
//| day_of_week - Day of the week, to which the setting of trade     |
//|               state applies to. Corresponds to the modifiers     |
//|               ENUM_DAY_OF_WEEK or the ALL_DAYS_OF_WEEK modifier  |
//| state       - Trading state.                                     |
//| Note: date components in time_begin and time_end are ignored.    |
//+------------------------------------------------------------------+
void CTradeState::SetTradeState(datetime time_begin,datetime time_end,int day_of_week,ENUM_TRADE_STATE state)
  {
   if(time_begin>time_end)
     {
      string sb = TimeToString(time_begin, TIME_MINUTES);
      string se = TimeToString(time_end, TIME_MINUTES);
      printf("Time "+sb+" must be more time "+se);
      return;
     }
   MqlDateTime btime,etime;
   TimeToStruct(time_begin,btime);
   TimeToStruct(time_end,etime);
   for(int day=0; day<ALL_DAYS_OF_WEEK; day++)
     {
      if(day!=day_of_week && day_of_week!=ALL_DAYS_OF_WEEK)
         continue;
      int i_day=day*60*24;
      int i_begin=i_day+(btime.hour*60)+btime.min;
      int i_end = i_day + (etime.hour*60) + etime.min;
      for(int i = i_begin; i <= i_end; i++)
         m_state[i]=state;
     }
  }
//+------------------------------------------------------------------+
//| Returns the previously set trading state for the current time    |
//+------------------------------------------------------------------+
ENUM_TRADE_STATE CTradeState::GetTradeState(void)
  {
   return GetTradeState(TimeCurrent());
  }
//+------------------------------------------------------------------+
//| Returns the previously set trading state for the passed          |
//| time.                                                            |
//+------------------------------------------------------------------+
ENUM_TRADE_STATE CTradeState::GetTradeState(datetime time_current)
  {
   MqlDateTime dt;
   TimeToStruct(time_current,dt);
   int i_day = dt.day_of_week*60*24;
   int index = i_day + (dt.hour*60) + dt.min;
   return m_state[index];
  }
//+------------------------------------------------------------------+
