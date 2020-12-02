/*
Este ponto de entrada tem a finalidade de compor a descrição dos serviços prestados na operação.
Essa descrição será utilizada para a impressão do RPS e para geração do arquivo de exportação para a prefeitura.
*/
#INCLUDE "TOTVS.CH"

User Function MTDescrNFe()

	Local aSC5     := SC5->(GetArea())
	Local aSF2     := SF2->(GetArea())
	Local aSD2     := SD2->(GetArea())
	Local cNFiscal := Padr(ParamIxb[1], TamSx3("F3_NFISCAL")[1])
	Local cSerie   := Padr(ParamIxb[2], TamSx3("F3_SERIE"  )[1])
	Local cCliente := Padr(ParamIxb[3], TamSx3("F2_CLIENTE")[1])
	Local cLoja    := Padr(ParamIxb[4], TamSx3("F3_LOJA"   )[1])
	Local cDescPV  := ""	//	Descrição do PV a ser gravado na NF em F2_XOBS
	Local cDescNF  := ""	//	Descrição tratada para ser transmitida
	Local cPedido  := ""
	Local cTxIRRF  := ""
	Local cTxCOFI  := ""
	Local cTxCSLL  := ""
	Local cTxPIS   := ""
	Local cTxINSS  := ""
	//Local cTxISS   := ""
	Local lLock    := .F.
	Local nValIRRF := 0
	Local nValINSS := 0
	//Local nValISS  := 0
	Local nValCOFI := 0
	Local nValCSLL := 0
	Local nValPIS  := 0
	Local nTotal   := 0

	If cNFiscal + cSerie + cCliente + cLoja <> SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2") + cNFiscal + cSerie + cCliente + cLoja))
	Endif

	nValIRRF := SF2->F2_VALIRRF
	nValPIS  := SF2->F2_VALPIS
	nValCOFI := SF2->F2_VALCOFI
	nValCSLL := SF2->F2_VALCSLL
	nValINSS := SF2->F2_VALINSS
	//nValISS  := SF2->F2_VALISS
	cTxIRRF  := Alltrim(TransForm(nValIRRF / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	cTxPIS   := Alltrim(TransForm(nValPIS  / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	cTxCOFI  := Alltrim(TransForm(nValCOFI / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	cTxCSLL  := Alltrim(TransForm(nValCSLL / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	cTxINSS  := Alltrim(TransForm(nValINSS / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	//cTxISS   := Alltrim(TransForm(nValISS  / SF2->F2_VALBRUT * 100, "@E 99.99")) + "%"
	nTotal   := SF2->F2_VALBRUT - (nValIRRF +  nValPIS + nValCSLL + nValCOFI + nValINSS)

	cDescPV  := AllTrim(_aTotal[23]) // Arquivo.ini de configuração do Município
	If !Empty(cDescPV)
		cDescPV += CRLF
	Endif
	If nValIRRF > 0
		cDescPV += "IR      (" + cTxIRRF + "): R$ " + TransForm(nValIRRF, "@E 999,999,999.99") + CRLF
	Endif
	If nValPIS  > 0
		cDescPV += "PIS     (" + cTxPIS  + "): R$ " + TransForm(nValPIS , "@E 999,999,999.99") + CRLF
	Endif
	If nValCSLL > 0
		cDescPV += "CSLL    (" + cTxCSLL + "): R$ " + TransForm(nValCSLL, "@E 999,999,999.99") + CRLF
	Endif
	If nValCOFI > 0
		cDescPV += "Confins (" + cTxCOFI + "): R$ " + TransForm(nValCOFI, "@E 999,999,999.99") + CRLF
	Endif
	If nValINSS > 0
		cDescPV += "INSS    (" + cTxINSS + "): R$ " + TransForm(nValINSS, "@E 999,999,999.99") + CRLF
	Endif
	//If nValISS  > 0
		//cDescPV += "ISS     (" + cTxISS  + "): R$ " + TransForm(nValISS , "@E 999,999,999.99") + CRLF
	//Endif
	cDescPV += "Total: R$ " + TransForm(nTotal, "@E 999,999,999.99") + CRLF

	SC5->(DbSetOrder(1))
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xfilial() + cNFiscal + cSerie + cCliente + cLoja))
	While !SD2->(Eof()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + cNFiscal + cSerie + cCliente + cLoja
		If cPedido <> SD2->D2_PEDIDO
			cPedido := SD2->D2_PEDIDO
			If SC5->(dbSeek(xFilial() + cPedido)) .And. !Empty(SC5->C5_XOBS)
				cDescPV += Alltrim(SC5->C5_XOBS) + CRLF
			Endif
		Endif
		SD2->(dbSkip())
	Enddo

	If !Empty(cDescPV) .And. SF2->F2_XOBS <> cDescPV
		lLock := RecLock("SF2")
		SF2->F2_XOBS := cDescPV
	Endif
	If lLock
		SF2->(msUnLock())
	Endif

	cDescNF := StrTran(cDescPV, CRLF, "|")
	//While "  " $ cDescNF	//	para remover excesso de espaços
		//cDescNF := StrTran(cDescNF, "  ", " ")
	//Enddo
	cDescNF := StrTran(cDescNF, "||", "|")
	IF Right(cDescNF, 1) == "|"
		cDescNF := Left(cDescNF, Len(cDescNF) - 1)
	Endif
	cDescNF := Alltrim(cDescNF)

	SC5->(RestArea(aSC5))
	SF2->(RestArea(aSF2))
	SD2->(RestArea(aSD2))

Return(cDescNF)
