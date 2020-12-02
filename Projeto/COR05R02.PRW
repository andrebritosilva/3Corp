#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COR05R02  ºAutor  ³Marcelo Franca      º Data ³  22/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de Romaneio                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR05R02()

	Local aPWiz    		:= {}
	Local aRetWiz  		:= {}
	Local lRet	   		:= .T.

	Private oFont10  	:=TFont():New("TIMES NEW ROMAN",,10,,.F.,,,,,.f.,.f.)
	Private oFont10n	:=TFont():New("TIMES NEW ROMAN",,10,,.T.,,,,,.f.,.f.)
	Private oFont12  	:=TFont():New("TIMES NEW ROMAN",,12,,.F.,,,,,.f.,.f.)
	Private oFont12n	:=TFont():New("TIMES NEW ROMAN",,12,,.T.,,,,,.f.,.f.)
	Private oFont13n	:=TFont():New("TIMES NEW ROMAN",,13,,.T.,,,,,.f.,.f.)

	aAdd(aPWiz,{ 1,"Pedido De: "                ,Space(TamSX3("C5_NUM")[1])     ,"","","SC5"	,"",    ,.T.})
	aAdd(aPWiz,{ 1,"Pedido Ate: "               ,Space(TamSX3("C5_NUM")[1])     ,"","","SC5"	,  ,    ,.T.})

	aAdd(aRetWiz,Space(TamSX3("C5_FILIAL")[1]))
	aAdd(aRetWiz,Space(TamSX3("C5_FILIAL")[1]))
	
	lRet:= ParamBox(aPWiz,"Impressão de Romaneio",@aRetWiz,,,,,,) 

	If !lRet

		Return()
		
	Else
		
		Processa({|| CORROM(Alltrim(aRetWiz[1]),Alltrim(aRetWiz[2]))},"Impressão de Romaneio")

	EndIf

Return()

Static Function CORROM(cPvde,cPvAte)

	Local oPrint
	Local cLocal			:= "\SPOOL\"
	Local cPath				:= GetTempPath()        //pdf
	Local cQuery			:= ""
	Local cPvde
	Local cPvAte
	Local nLin
	Local oBrush
	Local nSeq				:= 1
	Local nItens			:= 0
	Local nPagina			:= 1
	Local nAtuPag			:= 1
	Local cProd				:= ""
	Local nqtde				:= 0
	Local cLocal			:= ""

	cQuery := "SELECT C5_FILIAL," 
	cQuery += " C5_NUM," 
	cQuery += " C5_NOTA," 
	cQuery += " C5_SERIE," 
	cQuery += " C5_EMISSAO," 
	cQuery += " C5_CLIENTE," 
	cQuery += " C5_LOJACLI," 
	cQuery += " C5_TRANSP," 
	cQuery += " C5_PESOL," 
	cQuery += " C5_PBRUTO, " 
	cQuery += " C5_ESPECI1, " 	
	cQuery += " C5_TPFRETE," 
	cQuery += " C5_VOLUME1 " 	
	cQuery += "FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += "WHERE SC5.C5_NUM >= '" 	+ cPvde 	+ "' " 
	cQuery += "AND SC5.C5_NUM < = '" 	+ cPvAte 	+ "' " 
	cQuery += "AND SC5.D_E_L_E_T_ = ' '" 
	cQuery += "ORDER  BY C5_FILIAL, C5_NUM" 

	cQuery := ChangeQuery(cQuery) 
	
	If Select("TMPPED") > 0
		DbSelectArea("TMPPED")
		TMPPED->(DbCloseArea())
	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPED",.T.,.T.)
	
	TCSetField("TMPPED","C5_EMISSAO","D",8,0)

	TMPPED->(DbGoTop())
	
	While TMPPED->(!EOF())
	
		oPrint:=FWMSPrinter():New( TMPPED->C5_NUM + " - " + AllTrim(Posicione("SA1",1,xFilial("SA1") + TMPPED->C5_CLIENTE + TMPPED->C5_LOJACLI,"A1_NOME")),IMP_PDF,.F.,cLocal,.T.,,@oPrint,,,,,.T.)
		oPrint:SetPortrait()
		oPrint:SetPaperSize(9)	
		oPrint:SetMargin(10,10,10,10)
		oPrint:lServer  := .F.// Indica impressao via server (.T.) ou Local (.F.)
		oPrint:cPathPDF := "C:\TEMP\"
		oPrint:SetViewPDF( .T. )
		oPrint:setDevice(IMP_PDF)
		
		ProcRegua(TMPPED->(RecCount()))
		
		IncProc("Imprimindo Romaneio = " + TMPPED->C5_NUM)
		
		nAtuPag:= 1
		
		RomCabec(oPrint)

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
	
		If SA1->(DbSeek(xFilial("SA1") + TMPPED->C5_CLIENTE + TMPPED->C5_LOJACLI) )
	
			oPrint:Box(0115,0015, 0255, 0575)
	
			oPrint:Say(0125,0020, "Cliente:" 					  					, oFont12n)
			oPrint:Say(0125,0070, AllTrim(SA1->A1_NOME)							, oFont12)
			oPrint:Say(0125,0370, "Contato:" 					  					, oFont12n)
			oPrint:Say(0125,0455, SA1->A1_CONTATO							 		, oFont12)
				
				
			If Len(AllTrim(SA1->A1_CGC)) = 14
				oPrint:Say(0140,0020, "CNPJ.:" 					  						, oFont12n)
				oPrint:Say(0140,0070, SubStr(SA1->A1_CGC,1,2) + "." + SubStr(SA1->A1_CGC,3,3) + "." + SubStr(SA1->A1_CGC,6,3) + "/" + SubStr(SA1->A1_CGC,9,4) + "-" + SubStr(SA1->A1_CGC,13,2)		, oFont12)
	        Else
				oPrint:Say(0140,0020, "CPF:"									  			, oFont12n)	
				oPrint:Say(0140,0070, SubStr(SA1->A1_CGC,1,3) + "." + SubStr(SA1->A1_CGC,4,3) + "." + SubStr(SA1->A1_CGC,7,3) + "-" + SubStr(SA1->A1_CGC,10,2) , oFont12)
	        EndIf
		        
			oPrint:Say(0140,0370, "Fone:" 					  						, oFont12n)
			oPrint:Say(0140,0455, "(" + AllTrim(SA1->A1_DDD) + ")" + SA1->A1_TEL 	, oFont12)
	
			oPrint:Say(0155,0020, "I.E.:" 						  					, oFont12n)
			oPrint:Say(0155,0070, AllTrim(SA1->A1_INSCR)							, oFont12)//200
	
			oPrint:Say(0170,0020, "End.:"	 					  					, oFont12n)
			oPrint:Say(0170,0070, AllTrim(SA1->A1_END)							, oFont12)//200
				
			oPrint:Say(0185,0020, "Bairro:" 					  					, oFont12n)
			oPrint:Say(0185,0070, AllTrim(SA1->A1_BAIRRO)							, oFont12)
	
			oPrint:Say(0200,0020, "Cidade:" 					  					, oFont12n)
			oPrint:Say(0200,0070, AllTrim(SA1->A1_MUN)								, oFont12)
			oPrint:Say(0200,0370, "Nota Fiscal / Série.:"		  					, oFont12n)
			oPrint:Say(0200,0455, TMPPED->C5_NOTA + " / " + TMPPED->C5_SERIE 		, oFont12)
	
	
			oPrint:Say(0215,0020, "E-mail:" 					  					, oFont12n)
			oPrint:Say(0215,0070, AllTrim(SA1->A1_EMAIL)							, oFont12)
		
			If !Empty(TMPPED->C5_TRANSP)
		
				SA4->(DbSetOrder(1))
				SA4->(DbGoTop())
		
				If SA4->(DbSeek(xFilial("SA4") + TMPPED->C5_TRANSP ))
						
					oPrint:Say(0235,0020, "Transp.:" 			  							, oFont12n)
					oPrint:Say(0235,0070, TMPPED->C5_TRANSP + " - " + SA4->A4_NOME			, oFont12)
			
					oPrint:Say(0250,0020, "CNPJ.:"	 					  					, oFont12n)
					oPrint:Say(0250,0070, SubStr(SA4->A4_CGC,1,2) + "." + SubStr(SA4->A4_CGC,3,3) + "." + SubStr(SA4->A4_CGC,6,3) + "/" + SubStr(SA4->A4_CGC,9,4) + "-" + SubStr(SA4->A4_CGC,13,2)					, oFont12)
	
					oPrint:Say(0250,0370, "Telefone: " 										, oFont12n)
					oPrint:Say(0250,0455, "(" + AllTrim(SA4->A4_DDD) + ")" + SA4->A4_TEL	, oFont12)
							
				EndIf
				
			EndIF
				
		EndIf
			
		oBrush := Tbrush():New(,CLR_LIGHTGRAY)			
		oPrint:Box(0265,0015,0280,0575)
		oPrint:FillRect({0266,0016,0279,0574},oBrush)
		
		oPrint:Say( 0275,020, "Seq."					, oFont10n)
		oPrint:Say( 0275,040, "Código"					, oFont10n)
		oPrint:Say( 0275,080, "Descrição do Produto"	, oFont10n)
		oPrint:Say( 0275,450, "UM"						, oFont10n)//280
		oPrint:Say( 0275,475, "Qtde"					, oFont10n)//320
		oPrint:Say( 0275,510, "Dep"						, oFont10n)//370
		oPrint:Say( 0275,535, "NCM"						, oFont10n)//395
				
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		SC6->(DbSeek(xFilial("SC6") + TMPPED->C5_NUM)   )
		
		cQuery := "SELECT COUNT(C6_ITEM) CONTADOR " 
		cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 "
		cQuery += " WHERE SC6.D_E_L_E_T_ = ''"
		cQuery += " AND SC6.C6_NUM = '" + TMPPED->C5_NUM + "' "
		cQuery += " AND SC6.C6_FILIAL = '" + TMPPED->C5_FILIAL + "' "
		cQuery += " AND SC6.C6_XKIT <> '1' "

		cQuery := ChangeQuery(cQuery) 
	
		If Select("TMPSC6") > 0
			DbSelectArea("TMPSC6")
			TMPSC6->(DbCloseArea())
		EndIf

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSC6",.T.,.T.)

		TMPSC6->(DbGoTop())
	    
		nItens:= TMPSC6->(CONTADOR)
		
		While SC6->(!EOF()) .And. SC6->C6_NUM == TMPPED->C5_NUM

			If SC6->C6_XKIT == '1'
			
				SC6->(DbSkip())
				Loop
			
			EndIf 
		
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO ) )

			If !Empty(SubStr(AllTrim(SB1->B1_DESC),81))
				
				nItens++
				
			EndIf
			
		
			SC6->(DbSkip())
		
		End

		If nItens > 52

			nPagina++
			nItens:= nItens - 52
			nPagina+= Int(nItens/68)

		EndIf

		SC6->(DbSetOrder(12))
		SC6->(DbGoTop())
		SC6->(DbSeek(xFilial("SC6") + TMPPED->C5_NUM)   )
			
		nLin:= 290
		
		While SC6->(!EOF()) .And. SC6->C6_NUM == TMPPED->C5_NUM
		
			If SC6->C6_XKIT == '1'
			
				SC6->(DbSkip())
				Loop
			
			EndIf 
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO ) )
			
			oPrint:Say( nLin,020, StrZero(nSeq,3)								, oFont10)
			oPrint:Say( nLin,040, SC6->C6_PRODUTO								, oFont10)
			oPrint:Say( nLin,080, SubStr(SB1->B1_DESC,1,80)						, oFont10)
			oPrint:Say( nLin,450, SC6->C6_UM									, oFont10)
	
			cProd:= SC6->C6_PRODUTO
			cLocal:=  SC6->C6_LOCAL
			nQtde:=0
			
			While SC6->(!EOF()) .And. SC6->C6_NUM == TMPPED->C5_NUM .And. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProd) 
	
				If SC6->C6_XKIT == '1'
			
					SC6->(DbSkip())
					Loop
			
				EndIf 
				
				nQtde:= nQtde + SC6->C6_QTDVEN
				SC6->(DbSkip())
			
			End
			
			oPrint:SayAlign( nLin-8,450, TransForm(nQtde,TM(SC6->C6_QTDVEN,TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2]))	, oFont10,40, 0, , 1 )			              
			oPrint:Say( nLin,510, cLocal										, oFont10)			
			oPrint:Say( nLin,535, SB1->B1_POSIPI								, oFont10)			
			nSeq+=1

			If !Empty(SubStr(AllTrim(SB1->B1_DESC),81))
				
				nLin+=10
				oPrint:Say( nLin,080, SubStr(SB1->B1_DESC,81)					, oFont10)
				
			EndIf

			nLin+= 10
			//SC6->(DbSkip())

			If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
				//Imprimir numero da pagina
				oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
				oPrint:EndPage()
				
				RomCabec(oPrint)		
				                           
				nAtuPag++
				
				oPrint:Box(0115,0015,0130,0575)
				oPrint:FillRect({0116,0016,0129,0574},oBrush)
	
				oPrint:Say( 0125,020, "Seq."					, oFont10n)
				oPrint:Say( 0125,040, "Código"					, oFont10n)
				oPrint:Say( 0125,080, "Descrição do Produto"	, oFont10n)
				oPrint:Say( 0125,450, "UM"						, oFont10n)//280
				oPrint:Say( 0125,475, "Qtde"					, oFont10n)//320
				oPrint:Say( 0125,510, "Dep"						, oFont10n)//370
				oPrint:Say( 0125,535, "NCM"						, oFont10n)//395
				    
			    nLin:= 140
			
			EndIf
		
		End

		oPrint:Box(nLin,0015,nLin,0575)


		oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10n)//395
		
		//oPrint:Box(0820,0015,0820,0575)
		
	    oPrint:EndPage()
		
		TMPPED->(DbSkip())	

		oPrint:Preview()     // Comando para visualizar impressao
		
		//oPrint:Print()     // Comando para imprimir
		    
		FreeObj(oPrint)
			
		oPrint := Nil
		
	End

Return	

Static Function RomCabec(oPrint)

	Local cLogo99			:= "Triwave.bmp"
	Local cLogo01			:= "3Corp.bmp"
	Local oBrushCa
		
	oPrint:StartPage()
		
	oPrint:Box( 0020, 0015, 0105, 0575) //Caixa do Cabecalho 10 a mais que a ultima linha
	    
	If SM0->M0_CODIGO == "99"
		oPrint:SayBitmap(052,025,cLogo99,124.5,034)//Logotipo (Triwave)
    Else
		oPrint:SayBitmap(052,025,cLogo01,124.5,034)//Logotipo (Triwave)
	EndIf

	oBrushCa := Tbrush():New(,CLR_LIGHTGRAY)
	oPrint:Box(0030,0165,0050,0570)
	oPrint:FillRect({0031, 0166, 0049 , 0569},oBrushCa)		
	oPrint:Say(0045,0170, "ROMANEIO DE ENTREGA " + TMPPED->C5_NUM				, oFont13n)   
	oPrint:Say(0045,0455, SubStr(Dtos(TMPPED->C5_EMISSAO),7,2) + "/" + SubStr(Dtos(TMPPED->C5_EMISSAO),5,2) + "/" + SubStr(Dtos(TMPPED->C5_EMISSAO),1,4) , oFont13n)
		
	oPrint:Say(0065,00170, SM0->M0_NOMECOM										, oFont12)	//95
	oPrint:Say(0065,00455, "CNPJ: " + SubStr(SM0->M0_CGC,1,2) + "." + SubStr(SM0->M0_CGC,3,3) + "." + SubStr(SM0->M0_CGC,6,3) + "/" + SubStr(SM0->M0_CGC,9,4) + "-" + SubStr(SM0->M0_CGC,13,2)	, oFont12)	//110
	oPrint:Say(0075,00170, SM0->M0_ENDCOB										, oFont12)	
	oPrint:Say(0075,00455, "I.E.: " + SM0->M0_INSC								, oFont12)	
	oPrint:Say(0085,00170, AllTrim(SM0->M0_BAIRCOB) + " - CEP: " + SubStr(SM0->M0_CEPCOB,1,5) + "-" + SubStr(SM0->M0_CEPCOB,6,3) + " - " + AllTrim(SM0->M0_CIDCOB) + " / " + SM0->M0_ESTCOB	, oFont12)
	oPrint:Say(0095,00170, "FONE: " + SM0->M0_TEL								, oFont12)	

Return()