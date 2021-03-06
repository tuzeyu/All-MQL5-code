//+------------------------------------------------------------------+
//|                                               MoneyManagment.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include "XML\XMLbase.mqh"
#include "Message.mqh"
#include "Logs.mqh"
//+------------------------------------------------------------------+
//| Money management type.                                           |
//+------------------------------------------------------------------+
enum ENUM_MM_TYPE
  {
   MM_FIX_LOT,                       // Fixed lot
   MM_PERCENT_DEPO,                  // Percent of deposit
   MM_PERCENT_SL                     // Percent of SL
  };
//input ENUM_MM_TYPE TypeMM;           // Money Management type
//input double       FixLotOrPercent;  // Fixed lot or или %
//+------------------------------------------------------------------+
//| Money management module.                                         |
//+------------------------------------------------------------------+
class CMoneyManagment
  {
private:
   ENUM_MM_TYPE      m_type;                // MM type
   double            m_fix_lot;             // Fixed lot value.
   double            m_percent;             // Percent of deposit or % of SL
   string            m_symbol;              // Symbol
   CLog*             Log;                   // Logging



public:
                     CMoneyManagment(void);
/* Setting parameters */
   void              SetMMType(ENUM_MM_TYPE);
   void              SetLotFixed(double fix_lot);
   void              SetPercent(double percent);
   void              SetSymbol(string symbol);
   bool              ParseByXml(CXmlElement *xmlMM);
/* Lot calculation methods */
   double            GetLotFixed(void);
   double            GetLotByPercentDepo(void);
   double            GetLotByStopLoss(double stop_in_pips);
   double            GetLotByPrice(double max_price, double curr_price, double max_lot);
   double            GetLotByMoney(double money);
   double            GetLotByGO(double money);
   double            NormalizeLot(double lot);
  };
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
CMoneyManagment::CMoneyManagment(void)
  {
   Log = CLog::GetLog();
   SetMMType(MM_FIX_LOT);
   SetLotFixed(1.0);
   SetPercent(2.0);
   SetSymbol(Symbol());
  }
//+------------------------------------------------------------------+
//| Sets fixed lot returned by the GetLotFixed method                |
//+------------------------------------------------------------------+
void CMoneyManagment::SetLotFixed(double fix_lot)
  {
   m_fix_lot=fix_lot;
  }
//+------------------------------------------------------------------+
//| Sets percent used in calculations by the methods                 |
//| GetLotByPercentDepo and GetLotByStopLoss                         |
//+------------------------------------------------------------------+
void CMoneyManagment::SetPercent(double percent)
  {
   m_percent=percent;
  }
//+------------------------------------------------------------------+
//| Returns fixed lot or percent of deposit or percent of            |
//| Stop Loss depending on ENUM_MM_TYPE selected                     |
//+------------------------------------------------------------------+
double CMoneyManagment::GetLotFixed(void)
  {
   return m_fix_lot;
  }
//+------------------------------------------------------------------+
//| Sets money management type                                       |
//+------------------------------------------------------------------+
void CMoneyManagment::SetMMType(ENUM_MM_TYPE type)
  {
   m_type=type;
  }
//+------------------------------------------------------------------+
//| Sets the instrument for which you want to return the number of   |
//| lots.                                                            |
//+------------------------------------------------------------------+
void CMoneyManagment::SetSymbol(string symbol)
  {
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//| Parses XML settings for the current MM module                    |
//+------------------------------------------------------------------+
bool CMoneyManagment::ParseByXml(CXmlElement *xmlMM)
  {
   CXmlAttribute *attr=xmlMM.GetAttribute("Type");
   if(attr==NULL)
     {
      string text="Sending node <MoneyManagment> does not contain a mandatory attribute 'Type'";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      return false;
     }
   string sType=attr.GetValue();
   if(sType!="FixedLot" && sType!="PercentDepo" && sType!="PercentSL")
     {
      string text="Attribute 'Type' contain a wrong value: "+sType+". Value must be equal 'FixedLot', 'PercentDepo' ot 'PercentSL'";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      return false;
     }
   if(sType=="FixedLot")
     {
      CXmlAttribute *lot=xmlMM.GetAttribute("Lot");
      if(lot==NULL)
        {
         string text="Sending node <MoneyManagment> does not contain a mandatory attribute 'Lot'";
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         Log.AddMessage(msg);
         return false;
        }
      double d_lot=StringToDouble(lot.GetValue());
      if(d_lot<=0.0)
        {
         string text="Attribute 'Lot' contain a non-double value: "+lot.GetValue()+". The value must be greater than zero";
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         Log.AddMessage(msg);
         return false;
        }
      else
        {
         m_type=MM_FIX_LOT;
         m_fix_lot=d_lot;
        }
     }
   else
     {
      CXmlAttribute *per=xmlMM.GetAttribute("Percent");
      if(per==NULL)
        {
         string text="Sending node <MoneyManagment> does not contain a mandatory attribute 'Percent'";
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         Log.AddMessage(msg);
         return false;
        }
      double d_per=StringToDouble(per.GetValue());
      if(d_per<=0.0)
        {
         string text="Attribute 'Percent' contain a non-double value: "+per.GetValue()+". The value must be greater than zero";
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         Log.AddMessage(msg);
         return false;
        }
      else
        {
         m_type=sType=="PercentDepo" ? MM_PERCENT_DEPO : MM_PERCENT_SL;
         m_percent=d_per;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Returns the lot of the value equal to the predefined percent     |
//| of deposit. For example, if the value set by SetPercent is equal |
//| to 20.0 (20%), for a deposit of 1 million rubles, 3 contracts    |
//| of Si will be bought at 66,500 rubles each:                      |
//| (1,000,000 * 0.20)/65,500 rubles = 3.0534                        |
//+------------------------------------------------------------------+
double CMoneyManagment::GetLotByPercentDepo(void)
  {
   double point_cost=SymbolInfoDouble(m_symbol,SYMBOL_TRADE_TICK_VALUE);
   double last = SymbolInfoDouble(m_symbol, SYMBOL_LAST);
   double cost = point_cost*last;
   double limit= AccountInfoDouble(ACCOUNT_BALANCE)*m_percent;
   double lot=limit/cost;
   return MathRound(lot);
  }
//+------------------------------------------------------------------+
//| Returns the lot calculated so that if the price goes at the      |
//| distance in pips specified in stop_in_pips, loss or profit       |
//| would be equal to the percent of deposit specified in the        |
//| SetPercent method.                                               |
//+------------------------------------------------------------------+
double CMoneyManagment::GetLotByStopLoss(double stop_in_pips)
  {
   double point_cost=SymbolInfoDouble(m_symbol,SYMBOL_TRADE_TICK_VALUE);
   double cost=point_cost*stop_in_pips;
   double limit=AccountInfoDouble(ACCOUNT_BALANCE)*m_percent;
   double vol=MathAbs(limit/cost);
   return vol;
  }

double CMoneyManagment::GetLotByPrice(double max_price,double curr_price, double max_lot)
{
   if(curr_price >= max_price)
      return NormalizeLot(max_lot);
   double lots = max_price/curr_price;
   return NormalizeLot(lots);
}
//+------------------------------------------------------------------+
//| Returns the lot calculated so that opening it would require      |
//| the use of margin in the amount of specified in                  |
//| 'money'. For example, if money = 100 000 USD, and margin for     |
//| one lot is 4 000 USD, the function returns                       |
//| 100 000 / 4 000 = 25 lots                                        |
//+------------------------------------------------------------------+
double CMoneyManagment::GetLotByGO(double money)
{
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(free_margin < money)
   {
      string m = DoubleToString(free_margin, 2);
      string text = "The remaining free margin (" + m + ") is not sufficient to buy for the amount of " + DoubleToString(money, 1);
      CMessage* message = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(message);
      return 0.0;
   }
   double margin = SymbolInfoDouble(m_symbol, SYMBOL_MARGIN_INITIAL);
   if(margin == 0)
   {
      double vol_min = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      //if()
      string text = "Failed to obtain the margin value for symbol " + m_symbol +". The minimum volume will be used: " + DoubleToString(vol_min, 2);
      CMessage* message = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(message);
      return vol_min;
   }
   double lot = money/margin;
   lot = NormalizeLot(lot);
   if(lot == 0.0)
   {
      string text = "The remaining free margin is not sufficient to open a position even with the minimum lot. Add funds to the account balance.";
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
   }
   return lot;
}

double CMoneyManagment::NormalizeLot(double lot)
{
   double v_min = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   if(lot < v_min)
      return v_min;
   double v_max = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   if(lot > v_max)
      return v_max;
   double v_step = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
   int steps = (int)MathRound(lot/v_step);
   double n_lot = steps*v_step;
   return n_lot;
}
//+------------------------------------------------------------------+
