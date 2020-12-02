#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"        
#INCLUDE "TOPCONN.CH"          
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "RwMake.ch"
#INCLUDE "SHELL.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COR01R01  ºAutor  ³Marcelo Franca      º Data ³  22/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de Fatura                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR01R01()


	Local aPWiz    		:= {}
	Local aRetWiz  		:= {}
	Local lRet	   		:= .T.
		
	aAdd(aPWiz,{ 1,"Nota De: "                ,Space(TamSX3("F2_DOC")[1])     ,"","","SF2"	,"",    ,.T.})
	aAdd(aPWiz,{ 1,"Nota Ate: "               ,Space(TamSX3("F2_DOC")[1])     ,"","","SF2"	,  ,    ,.T.})
	aAdd(aPWiz,{ 1,"Série: "                  ,Space(TamSX3("F2_SERIE")[1])   ,"","",""	,  ,    ,.T.})
	aAdd(aPWiz,{ 1,"Emissão de: "             ,ddatabase   ,"@d","",""	,  ,    ,.T.})
	aAdd(aPWiz,{ 1,"Emissão até: "            ,ddatabase   ,"@d","",""	,  ,    ,.T.})

	aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))
	aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))
	aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))
	aAdd(aRetWiz,Space(TamSX3("F2_EMISSAO")[1]))
	aAdd(aRetWiz,Space(TamSX3("F2_EMISSAO")[1]))
	
	lRet:= ParamBox(aPWiz,"Impressão de Fatura",@aRetWiz,,,,,,) 

	If !lRet

		Return()
		
	Else
		
		Processa({|| U_CORFAT(Alltrim(aRetWiz[1]),Alltrim(aRetWiz[2]),Alltrim(aRetWiz[3]),Dtos(aRetWiz[4]),Dtos(aRetWiz[5]))},"Impressão de Fatura")

	EndIf

Return()

User Function CORFAT(cNfde,cNfAte,cSerie,dde,ddate)

	Local oPrint
	Local cLocal			:= "\SPOOL\"
	Local cPath				:= GetTempPath()        //pdf
	Local cQuery			:= ""
	Local cNfde
	Local cNfAte
	Local cSerie
	Local dde
	Local dVencimento
	Local ddate
	Local nLin              := 1
	Local aObs				:= {}
	Local nInt				:= 1
	
	Local oFont10  	:=TFont():New("TIMES NEW ROMAN",,10,,.F.,,,,,.f.,.f.)
	Local oFont10n	:=TFont():New("TIMES NEW ROMAN",,10,,.T.,,,,,.f.,.f.)
	Local oFont12  	:=TFont():New("TIMES NEW ROMAN",,12,,.F.,,,,,.f.,.f.)
	Local oFont12n	:=TFont():New("TIMES NEW ROMAN",,12,,.T.,,,,,.f.,.f.)
	Local oFont13n	:=TFont():New("TIMES NEW ROMAN",,13,,.T.,,,,,.f.,.f.)
	Local oFont20n	:=TFont():New("TIMES NEW ROMAN",,20,,.T.,,,,,.f.,.f.)
	
	Local nPagina			:= 1
	Local nAtuPag			:= 1
	Local nItens			:= 0
	
	Local nMemo				:= 0

	cQuery := "SELECT F2_FILIAL," 
	cQuery += " F2_DOC," 
	cQuery += " F2_SERIE," 
	cQuery += " F2_CLIENTE," 
	cQuery += " F2_LOJA, " 
	cQuery += " F2_EMISSAO, " 	
	cQuery += " F2_VALBRUT " 	
	cQuery += "FROM " + RetSqlName("SF2") + " SF2 "
	cQuery += "WHERE SF2.F2_DOC >= '" 	+ cNfde 	+ "' " 
	cQuery += "AND SF2.F2_DOC < = '" 	+ cNfAte 	+ "' " 
	cQuery += "AND SF2.F2_SERIE = '" 	+ cSerie 	+ "' " 
	cQuery += "AND SF2.F2_EMISSAO >= '" + dde 	+ "' " 
	cQuery += "AND SF2.F2_EMISSAO <= '"	+ ddate 	+ "' " 
	cQuery += "AND SF2.D_E_L_E_T_ = ' '" 
	cQuery += "ORDER  BY F2_FILIAL, F2_DOC" 

	cQuery := ChangeQuery(cQuery) 
	
	If Select("TMPFAT") > 0
		DbSelectArea("TMPFAT")
		TMPFAT->(DbCloseArea())
	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPFAT",.T.,.T.)
	
	TCSetField("TMPFAT","F2_EMISSAO","D",8,0)
	TCSetField("TMPFAT","F2_VALBRUT","N",14,2)	

	TMPFAT->(DbGoTop())
	
	While TMPFAT->(!EOF())
	
		oPrint:=FWMSPrinter():New( TMPFAT->F2_DOC + " - " + AllTrim(Posicione("SA1",1,xFilial("SA1") + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA,"A1_NOME")),IMP_PDF,.F.,cLocal,.T.,,@oPrint,,,,,.T.)
		oPrint:SetPortrait()
		oPrint:SetPaperSize(9)	
		oPrint:SetMargin(10,10,10,10)
		oPrint:lServer  := .F.// Indica impressao via server (.T.) ou Local (.F.)
		oPrint:cPathPDF := "C:\TEMP\"
		//oPrint:SetViewPDF( .F. )
		oPrint:SetViewPDF( .T. )
		//oPrint:setDevice(IMP_SPOOL)
		oPrint:setDevice(IMP_PDF)
		//oPrint:Setup() //Aparece tela de setup de impressao - RETIREI
		
		ProcRegua(TMPFAT->(RecCount()))
		
		IncProc("Imprimindo Fatura = " + TMPFAT->F2_DOC)

		nAtuPag:= 1
		
		RomCabec(oPrint)

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())

		If SA1->(DbSeek(xFilial("SA1") + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA) )

			oPrint:Say(0140,0020, "DADOS DE COBRANÇA:" 					  			, oFont12n)//170
	
			oPrint:Box(0150,0015, 0175, 0575) //Razao Social//180
			oPrint:Say(0160,0020, "Razão Social" 									, oFont10n)	//190
			oPrint:Say(0170,0020, AllTrim(SA1->A1_NOME)							, oFont12)//200
			
			oPrint:Box(0180,0015, 0205, 0575) //Endereco
			oPrint:Say(0190,0020, "Endereço"										, oFont10n)	//220
			oPrint:Say(0200,0020, AllTrim(SA1->A1_END)						  		, oFont12)//230
	
			oPrint:Box(0210,0015,0235, 0280) //Complemento
			oPrint:Say(0220,0020, "Complemento"										, oFont10n)	
			oPrint:Say(0230,0020, SubStr(SA1->A1_COMPLEM,1,50)				   		, oFont12)	                           
	
			oPrint:Box(0210,0285,0235,0335) //CEP
			oPrint:Say(0220,0290, "CEP"												, oFont10n)
			oPrint:Say(0230,0290, SubStr(SA1->A1_CEP,1,5) + "-" + SubStr(SA1->A1_CEP,6,3) , oFont12)
	
			oPrint:Box(0210,0340,0235,0575) //Bairro
			oPrint:Say(0220,0345, "Bairro"											, oFont10n)	
			oPrint:Say(0230,0345, SubStr(AllTrim(SA1->A1_BAIRRO),1,35)				, oFont12)	                           
	
			oPrint:Box(0240,0015,0265,0335) //Cidade
			oPrint:Say(0250,0020, "Cidade"								  			, oFont10n)	
			oPrint:Say(0260,0020, SubStr(AllTrim(SA1->A1_MUN),1,60)				, oFont12)
	
			oPrint:Box(0240, 0340, 0265, 0575) //Uf
			oPrint:Say(0250,0345, "UF"												, oFont10n)	
			oPrint:Say(0260,0345, SA1->A1_EST										, oFont12)	                           
	
			oPrint:Box(0270, 0015, 0295, 0335) //CNPJ

			If Len(AllTrim(SA1->A1_CGC)) = 14
				oPrint:Say(0280,0020, "CNPJ"							  			, oFont10n)	
				oPrint:Say(0290,0020, SubStr(SA1->A1_CGC,1,2) + "." + SubStr(SA1->A1_CGC,3,3) + "." + SubStr(SA1->A1_CGC,6,3) + "/" + SubStr(SA1->A1_CGC,9,4) + "-" + SubStr(SA1->A1_CGC,13,2)									, oFont12)
	        Else
				oPrint:Say(0280,0020, "CPF"									  			, oFont10n)	
				oPrint:Say(0290,0020, SubStr(SA1->A1_CGC,1,3) + "." + SubStr(SA1->A1_CGC,4,3) + "." + SubStr(SA1->A1_CGC,7,3) + "-" + SubStr(SA1->A1_CGC,10,2) , oFont12)
	        EndIf
	        
			oPrint:Box(0270, 0340, 0295, 0575)
			oPrint:Say(0280,0345, "I.E."												, oFont10n)	
			oPrint:Say(0290,0345, SA1->A1_INSCR											, oFont12)	                           
			
		EndIf
		
		oPrint:Box(0300, 0015, 0301, 0575)
		oPrint:Box(0300, 0015, 0300, 0575)	
		oPrint:Box(0300, 0015, 0301, 0575)		
		
		oPrint:Box(0310, 0015, 0335, 0575) //Valor por Extenso
		oPrint:Say(0320,0020, "Valor por Extenso"						  				, oFont10n)	
		oPrint:Say(0330,0020, SubStr(AllTrim(Extenso(TMPFAT->F2_VALBRUT,,1)),1,99)	, oFont12)
	
		oPrint:Box(0340,0015,0365,0500) //Valor por Extenso 
		oPrint:Say(0350,0020, "Valor por Extenso"						  				, oFont10n)	
	
		If !Empty(SubStr(AllTrim(Extenso(TMPFAT->F2_VALBRUT,,1)),100,86))
			oPrint:Say(0360,0020, SubStr(AllTrim(Extenso(TMPFAT->F2_VALBRUT,,1)),100,86)	, oFont12)
		EndIf
	
		oPrint:Box(0340,0505,0365,0575) //Valor da Fatura
		oPrint:Say(0350,0510, "Valor da Fatura"										, oFont10n)	
		oPrint:Say(0360,0510, TRANSFORM(TMPFAT->F2_VALBRUT,"@E 999,999,999.99")	, oFont12)	                           
		
		oPrint:Say(0380,0020, "Vencimento:"											, oFont12n)	
		
		SE1->(DbSetOrder(2))
		SE1->(DbGoTop())
		
		//SE1->(DbSeek(xFilial("SE1") + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA + TMPFAT->F2_SERIE + TMPFAT->F2_DOC )) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		dVencimento := BuscaVcto( TMPFAT->F2_CLIENTE , TMPFAT->F2_LOJA , TMPFAT->F2_SERIE , TMPFAT->F2_DOC )
		oPrint:Say(0380,0090, SubStr(dVencimento,7,2) + "/" + SubStr(dVencimento,5,2) + "/" + SubStr(dVencimento,1,4)	, oFont12)
		
		//oPrint:Say(0380,0090, SubStr(Dtos(SE1->E1_VENCTO),7,2) + "/" + SubStr(Dtos(SE1->E1_VENCTO),5,2) + "/" + SubStr(Dtos(SE1->E1_VENCTO),1,4)	, oFont12)	
		
		oPrint:Say(0400,0020, "DESCRIÇÃO"											, oFont12n)	
	
		oPrint:Say(0400,0340, "QUANTIDADE"											, oFont12n)//290 //315	
		oPrint:Say(0400,0415, "PREÇO UNITÁRIO"										, oFont12n)//390	
		oPrint:Say(0400,0505, "PREÇO TOTAL"											, oFont12n)//505	
		
		SD2->(DbSetOrder(3))  
		SD2->(DbGoTop())
		
		If SD2->(DbSeek(xFilial("SD2") + TMPFAT->F2_DOC + TMPFAT->F2_SERIE + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())
			
			If SC6->(DbSeek(xFilial("SC6") + SD2->D2_PEDIDO) )
			
				SC5->(DbSetOrder(1))
				SC5->(DbGoTop())
				
				SC5->(DbSeek(xFilial("SC5") + SD2->D2_PEDIDO ) )
		    	
		    	cQuery := "SELECT COUNT(C6_ITEM) CONTADOR " 
		    	cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 "
		    	cQuery += " WHERE SC6.D_E_L_E_T_ = ''"
		    	cQuery += " AND SC6.C6_NUM = '" + SD2->D2_PEDIDO + "' "
		    	cQuery += " AND SC6.C6_FILIAL = '" + SD2->D2_FILIAL + "' "
		    	
		    	cQuery := ChangeQuery(cQuery) 
	
		    	If Select("TMPSC6") > 0
		    		DbSelectArea("TMPSC6")
		    		TMPSC6->(DbCloseArea())
		    	EndIf

		    	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSC6",.T.,.T.)

		    	TMPSC6->(DbGoTop())
	    
		    	nItens:= TMPSC6->(CONTADOR)

		    	While SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE + SC6->C6_CLI + SC6->C6_LOJA == TMPFAT->F2_FILIAL + TMPFAT->F2_DOC + TMPFAT->F2_SERIE + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA .AND. SC6->(!EOF())

		    		If !Empty(SubStr(AllTrim(SC6->C6_DESCRI),61))
				
		    			nItens++
				
		    		EndIf
			
		
		    		SC6->(DbSkip())

		    	End 
		    	
		    	//130 colunas
		    	
		    	nMemo:= Int(Len(AllTrim(SC5->C5_XOBS)) / 130)

		    	aObs := SEPARA(SC5->C5_XOBS,chr(13)+chr(10),.T.)	
		    	
		    	nItens+= 2 + Len(aObs) + nMemo
		    	
		    	If nItens > 39

		    		nPagina++
		    		nItens:= nItens - 39
		    		nPagina+= Int(nItens/65)

		    	EndIf
		    
		    	SC6->(DbSetOrder(1))
		    	SC6->(DbGoTop())
		    	SC6->(DbSeek(xFilial("SC6") + SD2->D2_PEDIDO) )

		    	nLin:= 420
		    
				While SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE + SC6->C6_CLI + SC6->C6_LOJA == TMPFAT->F2_FILIAL + TMPFAT->F2_DOC + TMPFAT->F2_SERIE + TMPFAT->F2_CLIENTE + TMPFAT->F2_LOJA .AND. SC6->(!EOF())
			
					oPrint:Say(nLin,0020, SubStr(SC6->C6_DESCRI,1,60)										, oFont12)	

					oPrint:SayAlign( nLin-10,363, TransForm(SC6->C6_QTDVEN	,TM(SC6->C6_QTDVEN	,TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2]))	, oFont12,40, 0, , 1 )//305			              
					oPrint:SayAlign( nLin-10,447, TransForm(SC6->C6_PRCVEN	,TM(SC6->C6_PRCVEN	,TamSX3("C6_PRCVEN")[1],TamSX3("C6_PRCVEN")[2]))	, oFont12,55, 0, , 1 )			              
					oPrint:SayAlign( nLin-10,515, TransForm(SC6->C6_VALOR	,TM(SC6->C6_VALOR	,TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2]))		,oFont12,55, 0, , 1 )

					If !Empty(SubStr(AllTrim(SC6->C6_DESCRI),61))
				
						nLin+=10
						oPrint:Say( nLin,020, SubStr(SC6->C6_DESCRI,61)					, oFont12)
				
					EndIf

			    	nLin+=10
			    
					SC6->(DbSkip())
					
					//Verificar linhas
					If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
						//Imprimir numero da pagina
						oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
						oPrint:EndPage()
				
						RomCabec(oPrint)		
				                           
						nAtuPag++
				
						oPrint:Say(0140,0020, "DESCRIÇÃO"											, oFont12n)	
	
						oPrint:Say(0140,0340, "QUANTIDADE"											, oFont12n)//290 //315	
						oPrint:Say(0140,0415, "PREÇO UNITÁRIO"										, oFont12n)//390	
						oPrint:Say(0140,0505, "PREÇO TOTAL"											, oFont12n)//505	
						    
					    nLin:= 160
			
					EndIf
			
				End
			
			EndIF
	
	    EndIf

		nLin+=10	    
		oPrint:Say(nLin,0020, "OBSERVAÇÕES:"										, oFont12n)	
		//oPrint:Say(nLin,0020, SC5->C5_MENNOTA	, oFont12)	
		
		nLin+=10		

		For nInt:=1 to Len(aObs)
		
			oPrint:Say(nLin,0020, SubStr(aObs[nInt],1,130), oFont12)
			nLin+=10
			
			If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
				//Imprimir numero da pagina
				oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
				oPrint:EndPage()
				
				RomCabec(oPrint)		
				                           
				nAtuPag++
				
				oPrint:Say(nLin,0140, "OBSERVAÇÕES:"										, oFont12n)	
			    
			    nLin:= 160
			
			EndIf
			
			If !Empty(SubStr(aObs[nInt],131))

				oPrint:Say(nLin,0020, SubStr(aObs[nInt],131,130), oFont12)
				nLin+=10
			
			EndIf

			If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
				//Imprimir numero da pagina
				oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
				oPrint:EndPage()
				
				RomCabec(oPrint)		
				                           
				nAtuPag++
				
				oPrint:Say(nLin,0140, "OBSERVAÇÕES:"										, oFont12n)	
			    
			    nLin:= 160
			
			EndIf
        
			If !Empty(SubStr(aObs[nInt],262))

				oPrint:Say(nLin,0020, SubStr(aObs[nInt],262,130), oFont12)
				nLin+=10
			
			EndIf

			If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
				//Imprimir numero da pagina
				oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
				oPrint:EndPage()
				
				RomCabec(oPrint)		
				                           
				nAtuPag++
				
				oPrint:Say(nLin,0140, "OBSERVAÇÕES:"										, oFont12n)	
			    
			    nLin:= 160
			
			EndIf

			If !Empty(SubStr(aObs[nInt],393))

				oPrint:Say(nLin,0020, SubStr(aObs[nInt],393,130), oFont12)
				nLin+=10
			
			EndIf

			If nLin = 820 .And. SC6->(!EOF())//Ultima linha
	
				//Imprimir numero da pagina
				oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
				oPrint:EndPage()
				
				RomCabec(oPrint)		
				                           
				nAtuPag++
				
				oPrint:Say(nLin,0140, "OBSERVAÇÕES:"										, oFont12n)	
			    
			    nLin:= 160
			
			EndIf

		Next nInt

		
		//Limite ate a linha 0780

		If nLin >775

			oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
							
			oPrint:EndPage()
				
			RomCabec(oPrint)		
				                           
			nAtuPag++
				
			oPrint:Say(nLin,0140, "OBSERVAÇÕES:"										, oFont12n)	
			    
		EndIf
		
		oPrint:Box(0775,0020,0810,0287.5) //Caixa observerção lado esquerdo
		oPrint:Say(0790,0100, "RECIBO/FATURA"			, oFont20n)	
		oPrint:Say(0805,0120, "Nr. " + TMPFAT->F2_DOC	, oFont20n)	
		
		oPrint:Box(0775,292.5,0810,0575) //Caixa observerção lado direito
		oPrint:Say(0785,0297, "OPERAÇÃO NÃO SUJEITA A EMISSÃO DE NOTA FISCAL DE SERVIÇOS, "			, oFont10)	
		oPrint:Say(0795,0297, "VETADA COBRANÇA DE ISS CONFORME LEI FEDEREAL 116/03 PORTARIA" 		, oFont10)	
		oPrint:Say(0805,0297, "NR 74 DE 21/10/2003"	 		 										, oFont10)	

		oPrint:Say( 0820,525, "Página " + Strzero(nAtuPag,2) + " de " + Strzero(nPagina,2)			, oFont10)//395
	    
	    oPrint:EndPage()
		
		TMPFAT->(DbSkip())	

		oPrint:Preview()     // Comando para visualizar impressao
		
		//oPrint:Print()     // Comando para imprimir
		    
		FreeObj(oPrint)
			
		oPrint := Nil
		
	End

Return	

Static Function RomCabec(oPrint)

	Local cLogo99			:= "Triwave.bmp"
	Local cLogo01			:= "3Corp.bmp"
		
	Local oFont10  	:=TFont():New("TIMES NEW ROMAN",,10,,.F.,,,,,.f.,.f.)
	Local oFont10n	:=TFont():New("TIMES NEW ROMAN",,10,,.T.,,,,,.f.,.f.)
	Local oFont12  	:=TFont():New("TIMES NEW ROMAN",,12,,.F.,,,,,.f.,.f.)
	Local oFont12n	:=TFont():New("TIMES NEW ROMAN",,12,,.T.,,,,,.f.,.f.)
	Local oFont13n	:=TFont():New("TIMES NEW ROMAN",,13,,.T.,,,,,.f.,.f.)
		
	oPrint:StartPage()
		
	oPrint:Box( 0020, 0015, 0130, 0575) //Caixa do Cabecalho 10 a mais que a ultima linha
	    
	If SM0->M0_CODIGO == "99"
		oPrint:SayBitmap(052,025,cLogo99,124.5,034)//Logotipo (Triwave)
    Else
		oPrint:SayBitmap(052,025,cLogo01,124.5,034)//Logotipo (Triwave)
	EndIf
		
	oPrint:Say(0035,00170, "EMISSÃO: " + SubStr(Dtos(TMPFAT->F2_EMISSAO),7,2) + "/" + SubStr(Dtos(TMPFAT->F2_EMISSAO),5,2) + "/" + SubStr(Dtos(TMPFAT->F2_EMISSAO),1,4) , oFont13n)
	oPrint:Say(0035,00455, "RECIBO / FATURA NR:"  								, oFont13n)   
	oPrint:Say(0050,00455, TMPFAT->F2_DOC 										, oFont13n)   
	
	oPrint:Say(0065,00170, SM0->M0_NOMECOM										, oFont13n)	//95
	oPrint:Say(0080,00170, "CNPJ: "												, oFont10n)	//110
	oPrint:Say(0080,00210, SubStr(SM0->M0_CGC,1,2) + "." + SubStr(SM0->M0_CGC,3,3) + "." + SubStr(SM0->M0_CGC,6,3) + "/" + SubStr(SM0->M0_CGC,9,4) + "-" + SubStr(SM0->M0_CGC,13,2) , oFont10)	//110
	oPrint:Say(0080,00455, "I.E.: "												, oFont10n)	
	oPrint:Say(0080,00485, SM0->M0_INSC											, oFont10)	
	oPrint:Say(0090,00170, "Endereço: "											, oFont10n)	
	oPrint:Say(0090,00210, SM0->M0_ENDCOB										, oFont10)	
	oPrint:Say(0100,00170, "Bairro: "											, oFont10n)	
	oPrint:Say(0100,00210, SM0->M0_BAIRCOB										, oFont10)	
	oPrint:Say(0110,00170, "Município: "										, oFont10n)	
	oPrint:Say(0110,00210, SM0->M0_CIDCOB										, oFont10)	
	oPrint:Say(0110,00455, "UF: "												, oFont10n)	
	oPrint:Say(0110,00485, SM0->M0_ESTCOB										, oFont10)	
	oPrint:Say(0120,00170, "CEP: "										   		, oFont10n)	
	oPrint:Say(0120,00210, SubStr(SM0->M0_CEPCOB,1,5) + "-" + SubStr(SM0->M0_CEPCOB,6,3)	, oFont10)	//150 - 160
	
Return()

Static Function BuscaVcto(cCliente,cLoja,cPrefixo,cNum )

Local _aArea    := GetArea() 
Local cAliAux   := GetNextAlias()
Local dVenc     := ""
Local cQuery    := ""

//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

cQuery := "SELECT * FROM"
cQuery += RetSqlName("SE1") + " SE1 "
cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") +"'"
cQuery += " AND E1_CLIENTE = '" + cCliente +"'"
cQuery += " AND E1_LOJA = '" + cLoja +"'"
cQuery += " AND E1_PREFIXO = '" + cPrefixo +"'"
cQuery += " AND E1_NUM = '" + cNum +"'"
cQuery += " AND E1_TIPO = 'NF' "
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)  

dVenc := (cAliAux)->E1_VENCTO

(cAliAux)->(DbCloseArea())

RestArea(_aArea)

Return dVenc