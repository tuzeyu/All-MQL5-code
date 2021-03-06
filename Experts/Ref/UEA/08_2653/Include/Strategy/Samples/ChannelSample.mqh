//+------------------------------------------------------------------+
//|                                                ChannelSample.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CChannel : public CStrategy
  {
private:
   int               m_handle;   // The handle of the indicator that we will use
   int               m_period;   // Bollinger period
   double            m_std_dev;  // Standard deviation value
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   virtual void      OnSymbolChanged(string new_symbol);
   virtual void      OnTimeframeChanged(ENUM_TIMEFRAMES new_tf);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual bool      ParseXmlParams(CXmlElement *params);
   virtual string    ExpertNameFull(void);
   bool              CheckParams(void);
public:
                     CChannel(void);
                    ~CChannel(void);
   int               PeriodBands(void);
   void              PeriodBands(int period);
   double            StdDev(void);
   void              StdDev(double std);
  };
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
CChannel::CChannel(void) : m_handle(INVALID_HANDLE)
  {
  }
//+------------------------------------------------------------------+
//| The destructor frees the used handle of the indicator            |
//+------------------------------------------------------------------+
CChannel::~CChannel(void)
  {
   if(m_handle!=INVALID_HANDLE)
      IndicatorRelease(m_handle);
  }
//+------------------------------------------------------------------+
//| React to symbol change                                           |
//+------------------------------------------------------------------+
void CChannel::OnSymbolChanged(string new_symbol)
  {
   if(!CheckParams())return;
   if(m_handle!=INVALID_HANDLE)
      IndicatorRelease(m_handle);
   m_handle=iBands(new_symbol,Timeframe(),m_period,0,m_std_dev,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| React to timeframe change                                        |
//+------------------------------------------------------------------+
void CChannel::OnTimeframeChanged(ENUM_TIMEFRAMES new_tf)
  {
   if(!CheckParams())return;
   if(m_handle!=INVALID_HANDLE)
      IndicatorRelease(m_handle);
   m_handle=iBands(ExpertSymbol(),Timeframe(),m_period,0,m_std_dev,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Returns indicator period                                         |
//+------------------------------------------------------------------+
int CChannel::PeriodBands(void)
  {
   return m_period;
  }
//+------------------------------------------------------------------+
//| Sets indicator period                                            |
//+------------------------------------------------------------------+
void CChannel::PeriodBands(int period)
  {
   if(m_period == period)return;
   m_period=period;
   if(!CheckParams())return;
   if(m_handle!=INVALID_HANDLE)
      IndicatorRelease(m_handle);
   m_handle=iBands(ExpertSymbol(),Timeframe(),m_period,0,m_std_dev,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Sets the standard deviation value                                |
//+------------------------------------------------------------------+
double CChannel::StdDev(void)
  {
   return m_std_dev;
  }
//+------------------------------------------------------------------+
//| Sets the standard deviation value                                |
//+------------------------------------------------------------------+
void CChannel::StdDev(double std)
  {
   if(m_std_dev == std)return;
   m_std_dev=std;
   if(!CheckParams())return;
   if(m_handle!=INVALID_HANDLE)
      IndicatorRelease(m_handle);
   m_handle=iBands(ExpertSymbol(),Timeframe(),m_period,0,m_std_dev,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Long position opening rules                                      |
//+------------------------------------------------------------------+
void CChannel::InitBuy(const MarketEvent &event)
  {
   if(IsTrackEvents(event))return;                    // Enable logic only at the opening of a new bar
   if(positions.open_buy > 0)return;                  // Does not open more than one long position
   double bands[];
   if(CopyBuffer(m_handle, UPPER_BAND, 1, 1, bands) == 0)return;
   if(WS.Close[1]>bands[0])
      Trade.Buy(1.0,ExpertSymbol());
  }
//+------------------------------------------------------------------+
//| Long position closing rules                                      |
//+------------------------------------------------------------------+
void CChannel::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(IsTrackEvents(event))return;                    // Enable logic only at the opening of a new bar
   double bands[];
   if(CopyBuffer(m_handle, BASE_LINE, 1, 1, bands) == 0)return;
   double b = bands[0];
   double s = WS.Close[1];
   if(WS.Close[1]<bands[0])
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
//| Long position opening rules                                      |
//+------------------------------------------------------------------+
void CChannel::InitSell(const MarketEvent &event)
  {
   if(IsTrackEvents(event))return;                    // Enable logic only at the opening of a new bar
   if(positions.open_sell> 0)return;                  // Does not open more than one long position
   double bands[];
   if(CopyBuffer(m_handle, LOWER_BAND, 1, 1, bands) == 0)return;
   if(WS.Close[1]<bands[0])
      Trade.Sell(1.0,ExpertSymbol());
  }
//+------------------------------------------------------------------+
//| Long position closing rules                                      |
//+------------------------------------------------------------------+
void CChannel::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(IsTrackEvents(event))return;     // Enable logic only at the opening of a new bar
   double bands[];
   if(CopyBuffer(m_handle, BASE_LINE, 1, 1, bands) == 0)return;
   double b = bands[0];
   double s = WS.Close[1];
   if(WS.Close[1]>bands[0])
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
//| Filters incoming events. If the passed event is not              |
//| processed by the strategy, returns false; if it is processed     |
//| returns true.                                                    |
//+------------------------------------------------------------------+
bool CChannel::IsTrackEvents(const MarketEvent &event)
  {
//--- We handle only opening of a new bar on the working symbol and timeframe
   if(event.type != MARKET_EVENT_BAR_OPEN)return false;
   if(event.period != Timeframe())return false;
   if(event.symbol != ExpertSymbol())return false;
   return true;
  }
//+------------------------------------------------------------------+
//| The strategy's specific parameters are parsed inside it in       |
//| this method overridden from CStrategy                            |
//+------------------------------------------------------------------+
bool CChannel::ParseXmlParams(CXmlElement *params)
  {
   bool res=true;
   for(int i=0; i<params.GetChildCount(); i++)
     {
      CXmlElement *param=params.GetChild(i);
      string name=param.GetName();
      if(name=="Period")
         PeriodBands((int)param.GetText());
      else if(name=="StdDev")
         StdDev(StringToDouble(param.GetText()));
      else
         res=false;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| The full unique name of the EA                                   |
//+------------------------------------------------------------------+
string CChannel::ExpertNameFull(void)
  {
   string name=ExpertName();
   name += "[" + ExpertSymbol();
   name += "-" + StringSubstr(EnumToString(Timeframe()), 7);
   name += "-" + (string)PeriodBands();
   name += "-" + DoubleToString(StdDev(), 1);
   name += "]";
   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChannel::CheckParams(void)
  {
   if(ExpertSymbol()=="" || ExpertSymbol()==NULL)
      return false;
   if(m_std_dev==0.0)
      return false;
   if(m_period==0)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
