//+------------------------------------------------------------------+
//|                                                   TypeToChar.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Converts the uchar array into an array of custom type and        |
//| returns it by reference.                                         |
//+------------------------------------------------------------------+
template<typename T>
void CharToType(uchar& source[], T& result[])
{
   int t_size = sizeof(T);
   int s_size = (int)MathCeil(ArraySize(source) / (double)t_size);
   if(ArraySize(result) < s_size)
      ArrayResize(result, s_size);
   T var = 0;
   int ind = 0;
   for(int i = 0, c_size = t_size-1; i < ArraySize(source); i++, c_size--)
   {
      T svar = 0 | source[i];
      svar = (T)(svar << ((c_size)*t_size));
      var =  var | svar;
      if(c_size == 0)
      {
         c_size = t_size;
         result[ind] = var;
         var = 0;
         ind++;
      }
   }
}

//+------------------------------------------------------------------+
//| Converts a custom array to an array of the uchar type and        |
//| returns it by reference.                                         |
//+------------------------------------------------------------------+
template<typename T>
void TypeToChar(T& source[], uchar& result[])
{
   int t_size = sizeof(T);
   int s_size = t_size*ArraySize(source);
   if(ArraySize(result) < s_size)
      ArrayResize(result, s_size);
   T var = 0;
   int ind = 0;
   for(int i = 0, c_size = t_size-1; i < ArraySize(source); c_size--)
   {
      T mask = 0xff;
      mask = mask << (c_size*t_size);
      var = mask & source[i];
      var = var >> (c_size*t_size);
      uchar ch = (uchar)var;
      result[ind] = (uchar)var;
      ind++;
      if(c_size == 0)
      {
         c_size = t_size;
         i++;
      }
   }
}