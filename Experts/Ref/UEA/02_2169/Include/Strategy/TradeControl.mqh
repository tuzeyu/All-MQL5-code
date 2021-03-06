//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

/* 
   The class integrates an additional control module to the standard trading module CTradeCustom. Additions:
      1. If one of the trading methods is called earlier than in a certain number of milliseconds
   set using the TradeDelayMsc method, a warning message is displayed,
   notifying of too frequent trade operations and that the trading action fails.
      2. If during buying or selling of a required volume the volume of the aggregate net position
   exceeds the maximum allowed value set by the AddLimit method, the volume is corrected
   with a new value of the trade operation is rejected.
*/
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include <Dictionary.mqh>
#include <Strategy\TradeCustom.mqh>
#include <Strategy\Message.mqh>
#include <Strategy\Logs.mqh>
//+------------------------------------------------------------------+
//| The trade class based on CTradeCustom. It includes the           |
//| additional risk management modules.                              |
//+------------------------------------------------------------------+
class CTradeControl : public CTradeCustom
  {
private:
   uint              m_last_trade_action;     // The time of the last performed trading action.
   uint              m_trade_delay;           // Delay time in milliseconds, before which a re-order to execute a trade cannot be received.
   CLog*             Log;                     // Logging
public:
   CTradeCustom      Trade;                 // Basic trading module. Added to public to access the information about the deal status.
                     CTradeControl(void);
/* Configuring properties of CTradeCustom */

   void              TradeDelayMsc(uint msec);
   void              AsynchMode(bool asynch);

/* Overridden trading methods CTradeCustom */
   virtual bool      Buy(const double volume,const string symbol,const string comment="");
   virtual bool      Sell(const double volume,const string symbol,const string comment="");
   virtual bool      BuyLimit(const double volume,const double price,const string symbol,
                              const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
   virtual bool      BuyStop(const double volume,const double price,const string symbol,
                             const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
   virtual bool      SellLimit(const double volume,const double price,const string symbol,
                               const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
   virtual bool      SellStop(const double volume,const double price,const string symbol,
                              const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
  };
//+------------------------------------------------------------------+
//| Constructor.                                                     |
//+------------------------------------------------------------------+
CTradeControl::CTradeControl(void) : m_trade_delay(0),
                                     m_last_trade_action(0)
  {
   Log=CLog::GetLog();
  }
//+------------------------------------------------------------------+
//| Sets the flag of order execution in the asynchronous mode.       |
//+------------------------------------------------------------------+
void CTradeControl::AsynchMode(bool asynch)
  {
   Trade.SetAsyncMode(asynch);
  }
//+------------------------------------------------------------------+
//| A market Buy.                                                    |
//+------------------------------------------------------------------+
bool CTradeControl::Buy(const double volume,const string symbol,const string comment="")
  {
   bool res=CTradeCustom::Buy(volume,symbol,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
//| A market Buy.                                                    |
//+------------------------------------------------------------------+
bool CTradeControl::Sell(const double volume,const string symbol,const string comment="")
  {
   bool res=CTradeCustom::Sell(volume,symbol,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
//| Set buy-stop.                                                    |
//+------------------------------------------------------------------+
bool CTradeControl::BuyStop(const double volume,
                            const double price,
                            const string symbol,
                            const ENUM_ORDER_TYPE_TIME type_time=0,
                            const datetime expiration=0,
                            const string comment="")
  {
   bool res=CTradeCustom::BuyStop(volume,price,symbol,type_time,expiration,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
//| Set the sell stop order.                                         |
//+------------------------------------------------------------------+
bool CTradeControl::SellStop(const double volume,
                             const double price,
                             const string symbol,
                             const ENUM_ORDER_TYPE_TIME type_time=0,
                             const datetime expiration=0,
                             const string comment="")
  {
   bool res=CTradeCustom::SellStop(volume,price,symbol,type_time,expiration,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
//| Set the buy limit order.                                         |
//+------------------------------------------------------------------+
bool CTradeControl::BuyLimit(const double volume,
                             const double price,
                             const string symbol,
                             const ENUM_ORDER_TYPE_TIME type_time=0,
                             const datetime expiration=0,
                             const string comment="")
  {
   bool res=CTradeCustom::BuyLimit(volume,price,symbol,type_time,expiration,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
//| Set the buy limit order.                                         |
//+------------------------------------------------------------------+
bool CTradeControl::SellLimit(const double volume,
                              const double price,
                              const string symbol,
                              const ENUM_ORDER_TYPE_TIME type_time=0,
                              const datetime expiration=0,
                              const string comment="")
  {
   bool res=CTradeCustom::SellLimit(volume,price,symbol,type_time,expiration,comment);
   if(res)
      m_last_trade_action=GetTickCount();
   return res;
  }
//+------------------------------------------------------------------+
