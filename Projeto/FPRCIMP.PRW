#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FPRCIMP   ºAutor  ³Marcelo - Ethosx    º Data ³  22/11/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação apos digitar o preco unitario no Pedido de Venda º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ 06/02/2020, Mário Augusto Cavenaghi - EthosX:              º±±
±±º          ³             Não recalcula se confirmar o mesmo valor       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FPRCIMP(n)

	Local nValSOL  := 0
	Local nValIPI  := 0
	Local nMVlrTot := 0
	Local nPercDif := 0
	Local nDifVal  := 0
	Local nResTot  := 0
	Local nVlUnit  := 0
	Local nPRCVEN  := M->C6_PRCVEN
	Local nDecimal := TamSX3("C6_PRCVEN")[2]
	Local nPItem   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})
	Local nProduto := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
	Local nPQtdVen := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})
	Local nPPrcVen := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRCVEN"})
	Local nPPrcDig := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_XPRCANT"})
	Local nPTotal  := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR"})
	Local cTes     := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_TES"})

	Static _nPrcOri := 0
	Static _cNumero := ""
	Static _cItem := ""

	If ALTERA 
		If _cNumero <> SC5->C5_NUM .Or. _cItem <> aCols[n, nPItem] .Or. _nPrcOri == 0
			_cNumero := SC5->C5_NUM
			_cItem := aCols[n, nPItem]
			SC6->(dbSetOrder(1))
			SC6->(dbSeek(xFilial() + _cNumero + _cItem))
			_nPrcOri := SC6->C6_PRCVEN
		Endif
	Endif
	If _nPrcOri <> M->C6_PRCVEN
		If !l410Auto .And. FunName() == "MATA410" .And. M->C5_XCALIMP == "S"
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))
			MaFisIni(M->C5_CLIENTE, M->C5_LOJACLI, "C", M->C5_TIPO, M->C5_TIPOCLI,,, .F., "SB1")

			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1") + aCols[n, nProduto]))
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + aCols[n, cTes]))
			MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, aCols[n, nPQtdVen], aCols[n, nPPrcVen], 0, "", "", , 0, 0, 0, 0, aCols[n, nPTotal], 0, SB1->(RecNo()))

			nValSOL := MaFisRet(1, "IT_VALSOL")
			nValIPI := MaFisRet(1, "IT_VALIPI")
			MaFisEnd()

			nMVlrTot := aCols[N, nPTotal] + nValIPI + nValSOL
			nPercDif := (1 - (aCols[n, nPTotal] / nMVlrTot)) * 100
			nDifVal  := nMVlrTot * (nPercDif / 100)
			nResTot  := (nMVlrTot - nDifVal) / aCols[n, nPQtdVen]
			nDifVal  := nResTot * (nPercDif / 100)
			nVlUnit  := ROUND(nResTot - nDifVal, nDecimal)

			aCols[n, nPPrcVen]:= nVlUnit
			aCols[n, nPPrcDig]:= nPRCVEN
			aCols[n, nPTotal] := ROUND(nVlUnit * aCols[n, nPQtdVen], nDecimal)
			_nPrcOri := nVlUnit
		EndIf
	EndIf

Return(.T.)
