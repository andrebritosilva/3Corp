#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT100GE2()

Local aTitAtual := PARAMIXB[1]
Local nOpc      := PARAMIXB[2]
Local aHeadSE2  := PARAMIXB[3]
Local aParcelas := ParamIXB[5]
Local nX        := ParamIXB[4]
Local _aArea    := GetArea() 

SE2->E2_CCUSTO  := SD1->D1_CC

RestArea(_aArea)

Return