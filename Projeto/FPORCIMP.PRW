#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FPORCIMP   ºAutor  ³Marcelo - Ethosx    º Data ³  02/12/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação apos digitar o preco unitario no Orcamento       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ 06/02/2020, Mário Augusto Cavenaghi - EthosX:              º±±
±±º          ³             Não recalcula se confirmar o mesmo valor       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FPORCIMP()

	Local nValSOL  := 0
	Local nValIPI  := 0
	Local nMVlrTot := 0
	Local nPercDif := 0
	Local nDifVal  := 0
	Local nResTot  := 0
	Local nVlUnit  := 0
	Local nPrcVen  := M->CK_PRCVEN
	Local nDecimal := TamSX3("CK_PRCVEN")[2]

	Static _nPrcOri := 0
	Static _cNumero := ""
	Static _cItem := ""

	If ALTERA 
		If _cNumero <> SCJ->CJ_NUM .Or. _cItem <> TMP1->CK_ITEM .Or. _nPrcOri == 0
			_cNumero := SCJ->CJ_NUM
			_cItem := TMP1->CK_ITEM
			SCK->(dbSetOrder(1))
			SCK->(dbSeek(xFilial() + _cNumero + _cItem))
			_nPrcOri := SCK->CK_PRCVEN
		Endif
	Endif
	If _nPrcOri <> M->CK_PRCVEN
		If FunName() == "MATA415" .And. M->CJ_XCALIMP == "S"
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1") + M->CJ_CLIENTE + M->CJ_LOJA))
			MaFisIni(M->CJ_CLIENTE, M->CJ_LOJA, "C", M->CJ_TIPO, M->CJ_TIPOCLI,,, .F., "SB1")

			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1") + TMP1->CK_PRODUTO))
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + TMP1->CK_TES))
			MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, TMP1->CK_QTDVEN, TMP1->CK_PRCVEN, 0, "", "", , 0, 0, 0, 0, TMP1->CK_VALOR, 0, SB1->(RecNo()))

			nValSOL := MaFisRet(1,"IT_VALSOL")
			nValIPI := MaFisRet(1,"IT_VALIPI")
			MaFisEnd()

			nMVlrTot := TMP1->CK_VALOR + nValIPI + nValSOL
			nPercDif := (1 - (TMP1->CK_VALOR / nMVlrTot)) * 100
			nDifVal  := nMVlrTot * (nPercDif / 100)
			nResTot  := (nMVlrTot - nDifVal) / TMP1->CK_QTDVEN
			nDifVal  := nResTot * (nPercDif / 100)
			nVlUnit  := ROUND(nResTot - nDifVal, nDecimal)

			TMP1->CK_PRCVEN  := nVlUnit
			TMP1->CK_XPRCANT := nPrcVen
			TMP1->CK_VALOR   := ROUND(nVlUnit * TMP1->CK_QTDVEN, nDecimal)
			_nPrcOri := nVlUnit
		EndIf
	EndIf

Return(.T.)
