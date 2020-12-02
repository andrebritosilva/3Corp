#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.Ch"  

/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function CEXPBID2()
	U_CEXPBID3("S")
Return

User Function CEXPBID3(cTipo)

	Local cNomBlk	:= "U_CEXPBID3"
	Local lSeguir	:= LS_GETTOTAL(1) < 0
	Local lProcessa	:= .T.
	Local cDataIni	:= ""
	Local cDataFim	:= ""
	Local cHorIni	:= ""
	Local cHorFim	:= ""
		
	Private lSched	  := Iif( cTipo == "S" , .T. , .F. )
	Private aEmpresas := {"010"} //ARRAY COM OS CODIGOS DAS EMPRESAS
	
	Default cEmpJob	:= "01"
	Default cFilJob	:= "01"
	Default cTipo 	:= ''
		
	ConOut(PadC( Replicate("=",60),60 ))
	ConOut(PadC( DtoC( Date() ) + ' - ' + Time() + " INICIANDO JOB - CEXPBID3",60))
	ConOut(PadC( Replicate("=",60),60 ))

	If ValType( cEmpJob ) == "U" .Or. ValType( cFilJob ) == "U" .Or. Empty( cEmpJob ) .Or. Empty( cFilJob )
		Conout( "Empresa ou Filial faltando, verifique agendamento" )
	Else

		//Guarda Data e Hora inicial
		cDataIni	:= DtoC( Date() )
		cHorIni		:= Time()

		RpcClearEnv()
		RPCSetType( 3 )
		RpcSetEnv( cEmpJob, cFilJob, Nil, Nil, "FAT", Nil, {"SB1","SA1","SA2","SA3"} )

		//Verifica Lock de processamento
		While !LockbyName( cNomBlk, .T., .F., lSeguir )
			Sleep(50)
			nCont++
			ConOut(PadC("JOB - JTFABSCH ( Em Execucao, Aguardando Liberação ) Tentativa: " + StrZero(nCont,3) ,80))
			If nCont > 5
				ConOut(PadC("JOB - JTFABSCH ( Abortado por tempo limite )" ,80))
				lProcessa	:= .F.
				Exit
			EndIf
		End

		If lProcessa

			Conout( "Iniciando abertura de empresa" )
			Conout( "Parametros Recebidos" 			)
			Conout( "Empresa.: " + cEmpJob			)
			Conout( "Filial..: " + cFilJob 			)
			Conout( "Dt. Ini.: " + cDataIni 		)
			Conout( "Hr. Ini.: " + cHorIni 			)

			//Chamada para baixa de clientes / Pedidos
			MontaCAR(lSched) //TITULOS A PAGAR
			MontaSA1(lSched) //CLIENTES
			MontaSA2(lSched) //FORNECEDORES
			MontaSA3(lSched) //VENDEDORES
			MontaSED(lSched) //NATUREZA
			MontaSB1(lSched) //PRODUTOS
			MontaSB2(lSched) //SALDO DO PRODUTO
			MontaSE8(lSched) //SALDOS BANCARIOS
			MontaPED(lSched) //PEDIDOS DE VENDA
			MontaNFS(lSched) //NOTAS DE SAIDA
			MontaNFD(lSched) //NOTAS DE DEVOLUCOES
			MontaSA6(lSched) //DADOS DOS BANCOS


			//Guarda Data e Hora Final
			cDataFim	:= DtoC( Date() )
			cHorFim		:= Time()

			Conout( "Dt. Fim.: " + cDataFim 		)
			Conout( "Hr. Fim.: " + cHorFim 			)

		EndIf

		//Desbloqueia Semaforo
		UnLockbyName( cNomBlk, .T., .F., lSeguir )

	EndIf

	ConOut(PadC( Replicate("=",60),60 ))
	ConOut(PadC( DtoC( Date() ) + ' - ' + Time() + " FINALIZANDO JOB - CEXPBID3",60))
	ConOut(PadC( Replicate("=",60),60 ))

Return()
/*/{Protheus.doc} MontaSA6
//TODO Descrição auto-gerada.
@author jnrtcn
@since 12/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSA6(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimBancos"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " SELECT
		cSq2 += "   Id_Empresa		= '1'
		cSq2 += "  ,Id_Filial		= A6_FILIAL
		cSq2 += "  ,Id_Banco		= Rtrim(A6_COD)
		cSq2 += "  ,Id_Agencia		= Rtrim(A6_AGENCIA)
		cSq2 += "  ,Id_ContaCorrente= Rtrim(A6_NUMCON)
		cSq2 += "  ,NomeBanco		= Rtrim(A6_NOME)
		cSq2 += "  ,Id_Chave		= Rtrim(A6_COD) + Rtrim(A6_AGENCIA) + Rtrim(A6_NUMCON)
		cSq2 += "  ,FluxoCaixa		= Rtrim(A6_FLUXCAI)
		cSq2 += "  From SA6" + aEmpresas[nX] + " SA6 "
		cSq2 += "  WHERE D_E_L_E_T_=''

	Next nX 

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())


	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Banco"     			,"QRY->Id_Banco" 			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Agencia"  	 		,"QRY->Id_Agencia"  		,"@!",05,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ContaCorrente"  		,"QRY->Id_ContaCorrente" 	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Chave" 		 		,"QRY->Id_Chave"		 	,"@!",20,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomeBanco"  			,"QRY->NomeBanco" 			,"@!",60,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf

Return()


/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaNFD(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftDevolucoes"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " SELECT
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= D1_FILIAL,
		cSq2 += "  Id_ClientUsar		= RTRIM(D1_FORNECE)+RTRIM(D1_LOJA),
		cSq2 += "  Id_Cliente			= RTRIM(D1_FORNECE)			,
		cSq2 += "  Id_Loja				= RTRIM(ISNULL(D1_LOJA,''))	,
		cSq2 += "  Id_Cfop				= RTRIM(D1_CF)				,
		cSq2 += "  Id_Vendedor			= F2_VEND1					,
		cSq2 += "  Id_ClienteOrigem		= F1_CLIORI					,
		cSq2 += "  Almoxarifado			= RTRIM(D1_LOCAL)			,
		cSq2 += "  Item  				= RTRIM(ISNULL(D1_ITEM,'')),
		cSq2 += "  VlrUnidade  			= RTRIM(ISNULL(D1_VUNIT,'')),
		cSq2 += "  DtEmissao			= CONVERT(DATE,F1_EMISSAO),
		cSq2 += "  DtDigitacao		    = CONVERT(DATE,F1_DTDIGIT),
		cSq2 += "  TipoFaturamento		= RTRIM(F1_TIPO)			,
		cSq2 += "  Id_ProdutoUsar		= RTRIM(D1_FILIAL)+RTRIM(D1_COD)				,
		cSq2 += "  Id_Produto			= RTRIM(D1_COD)				,
		cSq2 += "  Documento			= RTRIM(D1_DOC),
		cSq2 += "  Serie				= RTRIM(D1_SERIE),
		cSq2 += "  NfOri				= RTRIM(D1_NFORI),
		cSq2 += "  SerOri				= RTRIM(D1_SERIORI),
		cSq2 += "  ItemOri				= RTRIM(D1_ITEMORI),
		cSq2 += "  Qtde					= D1_QUANT,
		cSq2 += "  VlrTotal				= D1_TOTAL,
		cSq2 += "  VlrIcms				= D1_VALICM,
		cSq2 += "  VlrIpi				= D1_VALIPI,
		cSq2 += "  VlrIcmsSt			= D1_ICMSRET,
		cSq2 += "  VlrCofins			= D1_VALIMP5,
		cSq2 += "  VlrPis				= D1_VALIMP6,
		cSq2 += "  VlrCustoProduto		= D1_CUSTO,
		cSq2 += "  CodigoTES			= RTRIM(F4_CODIGO),
		cSq2 += "  DescricaoTES			= RTRIM(F4_TEXTO),
		cSq2 += "  MovimentaEstoqueTES	= RTRIM(F4_ESTOQUE),
		cSq2 += "  GeraFinanceiroTES	= RTRIM(F4_DUPLIC)
		cSq2 += " FROM SF1" + aEmpresas[nX] + " SF1 "
		cSq2 += " INNER JOIN SD1" + aEmpresas[nX] + " SD1 On D1_FILIAL =F1_FILIAL AND  D1_DOC =  F1_DOC AND  D1_SERIE =  F1_SERIE  AND  D1_FORNECE =  F1_FORNECE	 AND  D1_LOJA =  F1_LOJA "
		cSq2 += " INNER JOIN SF4" + aEmpresas[nX] + " SF4 ON F4_CODIGO = D1_TES AND  SF4.D_E_L_E_T_= ' ' 
		cSq2 += " INNER JOIN SF2" + aEmpresas[nX] + " SF2 ON F2_DOC = D1_NFORI AND F2_SERIE = D1_SERIORI AND F2_LOJA = D1_LOJA   AND SF2.D_E_L_E_T_= ' ' AND F2_FILIAL=D1_FILIAL "
		cSq2 += " WHERE SD1.D_E_L_E_T_ = ' '	 AND
		cSq2 += " SF1.D_E_L_E_T_=' '    AND 
		cSq2 += " D1_TIPO	   = 'D' AND
		cSq2 += " NOT (D1_TIPODOC >= '50') 

	Next nX 

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClientUsar" 			,"QRY->Id_ClientUsar"	 	,"@!",14,0,"","","C","TEM","R"}) 
	aadd(aHeader, {"Id_Cliente"  			,"QRY->Id_Cliente"		 	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Loja"     			,"QRY->Id_Loja"  		 	,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClienteOrigem"		,"QRY->Id_ClienteOrigem" 	,"@!",10,0,"","","C","TEM","R"}) 
	aadd(aHeader, {"Almoxarifado"   		,"QRY->Almoxarifado"		,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoFaturamento"		,"QRY->TipoFaturamento"		,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Documento"   			,"QRY->Documento"			,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"Serie"   				,"QRY->Serie"				,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtEmissao"   			,"QRY->DtEmissao"			,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"Id_Vendedor"   			,"QRY->Id_Vendedor"			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cfop"   				,"QRY->Id_Cfop"				,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Produto"   			,"QRY->Id_Produto"			,"@!",55,0,"","","C","TEM","R"})
	//aadd(aHeader, {"Contrato"  				,"QRY->Contrato"			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Item"   				,"QRY->Item"				,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"NfOri"   				,"QRY->NfOri"				,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"SerOri"   				,"QRY->SerOri"				,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"ItemOri"   				,"QRY->ItemOri"				,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"Qtde"		   			,"QRY->Qtde"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrTotal"   			,"QRY->VlrTotal"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIcms"   				,"QRY->VlrIcms"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIpi"   				,"QRY->VlrIpi"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIcmsSt"   			,"QRY->VlrIcmsSt"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCofins"   			,"QRY->VlrCofins"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrPis"   				,"QRY->VlrPis"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCustoProduto"   		,"QRY->VlrCustoProduto"		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"CodigoTES"   			,"QRY->CodigoTES"			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescricaoTES"   		,"QRY->DescricaoTES"		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"MovimentaEstoqueTES"	,"QRY->MovimentaEstoqueTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"GeraFinanceiroTES"  	,"QRY->GeraFinanceiroTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return()
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaNFS(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftFaturamento"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF
		cSq2 += " SELECT
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= D2_FILIAL,
		cSq2 += "  Id_ClientUsar		= RTRIM(D2_CLIENTE)+RTRIM(D2_LOJA),
		cSq2 += "  Id_Cliente			= RTRIM(D2_CLIENTE)			,
		cSq2 += "  Id_Loja				= RTRIM(ISNULL(D2_LOJA,''))	,
		cSq2 += "  Id_Cfop				= RTRIM(D2_CF)				,
		cSq2 += "  Almoxarifado			= RTRIM(D2_LOCAL)			,
		cSq2 += "  Item					= RTRIM(D2_ITEM)				,
		cSq2 += "  Id_Vendedor			= RTRIM(ISNULL(F2_VEND1,'')),
		cSq2 += "  DtEmissao			= CONVERT(DATE,F2_EMISSAO)	,
		cSq2 += "  TipoFaturamento		= RTRIM(F2_TIPO)			,
		cSq2 += "  Id_ProdutoUsar		= D2_FILIAL + RTRIM(D2_COD)				,
		cSq2 += "  Id_Produto			= RTRIM(D2_COD)				,
		cSq2 += "  Documento			= RTRIM(D2_DOC)				,
		cSq2 += "  Serie				= RTRIM(D2_SERIE)			,
		cSq2 += "  Qtde					= D2_QUANT					,
		cSq2 += "  VlrTotal				= D2_TOTAL					,
		//cSq2 += "  Contrato				= ''						,
		cSq2 += "  Contrato				= (SELECT TOP 1 C5_X_CONTR FROM SC5" + aEmpresas[nX] + " SC5 WHERE SC5.C5_FILIAL = SD2.D2_FILIAL AND SC5.C5_NOTA = SD2.D2_DOC )	,
		cSq2 += "  VlrFatSemimpostos	= ISNULL(D2_TOTAL - D2_IPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_VALISS - D2_VALCSL - D2_VALIRRF,0),
		cSq2 += "  VlrFatSemICMS_IPI	= ISNULL(D2_TOTAL-D2_VALICM-D2_IPI,0),
		cSq2 += "  VlrIcms				= D2_VALICM					,
		cSq2 += "  VlrIpi				= D2_IPI					,
		cSq2 += "  VlrIcmsSt			= D2_ICMSRET				,
		cSq2 += "  VlrCofins			= D2_VALIMP5				,
		cSq2 += "  VlrPis				= D2_VALIMP6				,
		cSq2 += "  VlrMercadoria  		= F2_VALMERC				,
		cSq2 += "  VlrTotalImpostos		= ISNULL(D2_IPI + D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALISS + D2_VALCSL +D2_VALIRRF,0),
		cSq2 += "  VlrCustoProduto		= isnull(D2_CUSTO1,0),
		cSq2 += "  CodigoTES			= RTRIM(F4_CODIGO),
		cSq2 += "  DescricaoTES			= RTRIM(F4_TEXTO),
		cSq2 += "  MovimentaEstoqueTES	= RTRIM(F4_ESTOQUE),
		cSq2 += "  GeraFinanceiroTES	= RTRIM(F4_DUPLIC)
		cSq2 += "  FROM SD2" + aEmpresas[nX] + " SD2 "
		cSq2 += "  INNER JOIN SF4" + aEmpresas[nX] + " SF4  ON F4_CODIGO = D2_TES AND  SF4.D_E_L_E_T_= ' ' 
		cSq2 += "  INNER JOIN SF2" + aEmpresas[nX] + " SF2  ON F2_FILIAL	= D2_FILIAL		AND F2_CLIENTE  = D2_CLIENTE	AND F2_LOJA     = D2_LOJA       AND F2_DOC		= D2_DOC		AND F2_SERIE	= D2_SERIE		
		cSq2 += "  WHERE
		cSq2 += "  SD2.D_E_L_E_T_ =  ' ' AND
		cSq2 += "  SF2.D_E_L_E_T_=' ' AND 
		cSq2 += "  D2_TIPO NOT IN ('D','B')	AND
		cSq2 += "  NOT (D2_TIPODOC >= '50') 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClientUsar"			,"QRY->Id_ClientUsar"	 	,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cliente"  			,"QRY->Id_Cliente"		 	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Loja"     			,"QRY->Id_Loja"  		 	,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"Almoxarifado"   		,"QRY->Almoxarifado"		,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoFaturamento"		,"QRY->TipoFaturamento"		,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Documento"   			,"QRY->Documento"			,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"Serie"   				,"QRY->Serie"				,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtEmissao"   			,"QRY->DtEmissao"			,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"Id_Vendedor"   			,"QRY->Id_Vendedor"			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cfop"   				,"QRY->Id_Cfop"				,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Produto"   			,"QRY->Id_Produto"			,"@!",55,0,"","","C","TEM","R"})
	aadd(aHeader, {"Contrato"  				,"QRY->Contrato"			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Qtde"		   			,"QRY->Qtde"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrTotal"   			,"QRY->VlrTotal"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrFatSemimpostos"		,"QRY->VlrFatSemimpostos"	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrFatSemICMS_IPI"		,"QRY->VlrFatSemICMS_IPI"	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIcms"   				,"QRY->VlrIcms"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIpi"   				,"QRY->VlrIpi"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrIcmsSt"   			,"QRY->VlrIcmsSt"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCofins"   			,"QRY->VlrCofins"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrPis"   				,"QRY->VlrPis"				,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrMercadoria"   		,"QRY->VlrMercadoria"		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrTotalImpostos"   	,"QRY->VlrTotalImpostos"	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCustoProduto"   		,"QRY->VlrCustoProduto"		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"CodigoTES"   			,"QRY->CodigoTES"			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescricaoTES"   		,"QRY->DescricaoTES"		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"MovimentaEstoqueTES"	,"QRY->MovimentaEstoqueTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"GeraFinanceiroTES"  	,"QRY->GeraFinanceiroTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return()
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaPED(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftPedidosVendas"
	PRIVATE aHeader := {}
	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF
		cSq2 += " SELECT
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= C5_FILIAL,
		cSq2 += "  Pedido				= C5_NUM,
		cSq2 += "  Tipo					= C5_TIPO,
		cSq2 += "  Id_ClientUsar		= C5_CLIENTE+C5_LOJACLI,
		cSq2 += "  Id_Cliente			= C5_CLIENTE,
		cSq2 += "  Id_Loja				= C5_LOJACLI,
		cSq2 += "  TipoCliente			= C5_TIPOCLI,
		cSq2 += "  DtEmissao			= Convert(Date,C5_EMISSAO),
		cSq2 += "  DtEntrega			= Convert(Date,C6_ENTREG),
		cSq2 += "  TabelaPreco			= C5_TABELA,
		cSq2 += "  Id_Vendedor			= C5_VEND1,
		cSq2 += "  ComissaoVendedor		= C5_COMIS1 ,
		cSq2 += "  Id_Cfop				= C6_CF,
		cSq2 += "  Id_ProdutoUsar		= C6_FILIAL+C6_PRODUTO,
		cSq2 += "  Id_Produto			= C6_PRODUTO,
		cSq2 += "  Item					= C6_ITEM,
		cSq2 += "  QtdePedido			= C6_QTDVEN,
		cSq2 += "  QtdeEntregue			= C6_QTDENT,
		cSq2 += "  VlrTotal 			= C6_VALOR,
		cSq2 += "  VlrPrecoVenda		= C6_PRCVEN,
		//cSq2 += "  Contrato				= '' ,
		cSq2 += "  Contrato				= C5_X_CONTR ,
		cSq2 += "  VlrCarteira          = ISNULL((C6_QTDVEN - C6_QTDENT),0) * ISNULL(C6_PRCVEN,0),
		cSq2 += "  CodigoTES			= RTRIM(F4_CODIGO),
		cSq2 += "  DescricaoTES			= RTRIM(F4_TEXTO),
		cSq2 += "  MovimentaEstoqueTES	= RTRIM(F4_ESTOQUE),
		cSq2 += "  GeraFinanceiroTES	= RTRIM(F4_DUPLIC)
		cSq2 += "  From	SC5" + aEmpresas[nX] + " SC5 " 
		cSq2 += "  INNER JOIN SC6" + aEmpresas[nX] +" SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_=' '
		cSq2 += "  INNER JOIN SF4" + aEmpresas[nX] +" SF4 ON F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_=' '
		cSq2 += "                   				AND F4_DUPLIC = 'S'
		cSq2 += "  WHERE
		cSq2 += "  SC5.D_E_L_E_T_=' ' AND (C6_QTDVEN - C6_QTDENT) > 0

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Pedido"     			,"QRY->Pedido" 				,"@!",06,0,"","","C","TEM","R"})
	aadd(aHeader, {"Tipo"  	 				,"QRY->Tipo"  				,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClientUsar"  		,"QRY->Id_ClientUsar"	 	,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cliente"  			,"QRY->Id_Cliente"		 	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Loja"     			,"QRY->Id_Loja"  		 	,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoCliente"   			,"QRY->TipoCliente"			,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtEmissao"   			,"QRY->DtEmissao"			,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"DtEntrega"   			,"QRY->DtEntrega"			,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"Contrato"   			,"QRY->Contrato"			,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"TabelaPreco"   			,"QRY->TabelaPreco"			,"@!",3,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Vendedor"   			,"QRY->Id_Vendedor"			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"ComissaoVendedor"   	,"QRY->ComissaoVendedor"	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"Id_Cfop"   				,"QRY->Id_Cfop"				,"@!",4,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Produto"   			,"QRY->Id_Produto"			,"@!",55,0,"","","C","TEM","R"})
	aadd(aHeader, {"Item"   				,"QRY->Item"				,"@!",4,0,"","","C","TEM","R"})
	aadd(aHeader, {"QtdeEntregue"   		,"QRY->QtdeEntregue"		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrTotal"   			,"QRY->VlrTotal"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"QtdePedido"   			,"QRY->QtdePedido"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrPrecoVenda"   		,"QRY->VlrPrecoVenda"		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCarteira"   			,"QRY->VlrCarteira"			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"CodigoTES"   			,"QRY->CodigoTES"			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescricaoTES"   		,"QRY->DescricaoTES"		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"MovimentaEstoqueTES"	,"QRY->MovimentaEstoqueTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"GeraFinanceiroTES"  	,"QRY->GeraFinanceiroTES"	,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return()
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSE8(lSched)

	Local cArqTrb1	:= CriaTrab(NIL,.F.)
	Local aStru     := {}
	Local cSq2 		:= ""
	Local aBanco	:= {}
	Local aChave	:= {}

	PRIVATE cArquivo:= "ftSaldosBancarios"
	PRIVATE aHeader := {}
	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " SELECT
		cSq2 += "    Id_Empresa			= '1'					
		cSq2 += "   ,Id_Filial			= E8_FILIAL	
		cSq2 += "   ,Id_Banco			= RTRIM(E8_BANCO)	
		cSq2 += "   ,Id_Agencia			= RTRIM(E8_AGENCIA)
		cSq2 += "   ,Id_ContaCorrente	= RTRIM(E8_CONTA)	
		cSq2 += "   ,Id_Chave           = RTRIM(E8_BANCO) + RTRIM(E8_AGENCIA) + RTRIM(E8_CONTA)
		cSq2 += "   ,DtSalat			= MAX( E8_DTSALAT )	
		cSq2 += " FROM SE8" + aEmpresas[nX] + " SE8 "
		cSq2 += " WHERE SE8.D_E_L_E_T_=' '
		cSq2 += " GROUP BY E8_FILIAL , E8_BANCO	, E8_AGENCIA , E8_CONTA

		If ( Select( "QRY" ) <> 0 )
			dbSelectArea ( "QRY" )
			dbCloseArea ()
		Endif

		dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

		QRY->(dbGoTop())
		While QRY->(!Eof())

			nPos := aScan( aChave , {|x| x[1] = QRY->Id_Chave })
			If nPos == 0
				aadd( aChave , {    QRY->Id_Chave ,; 
				QRY->DtSalat })
			EndIf

			QRY->(dbSkip())
		End 

		cSq2 := ""
		For nJ:=1 to len(aChave)

			IF cSq2 <> ""
				cSq2 += "UNION ALL "
			ENDIF

			cSq2 += " SELECT
			cSq2 += "    Id_Empresa			= '1'					
			cSq2 += "   ,Id_Filial			= E8_FILIAL	
			cSq2 += "   ,Id_Banco			= RTRIM(E8_BANCO)	
			cSq2 += "   ,Id_Agencia			= RTRIM(E8_AGENCIA)
			cSq2 += "   ,Id_ContaCorrente	= RTRIM(E8_CONTA)	
			cSq2 += "   ,Id_Chave           = RTRIM(E8_BANCO) + RTRIM(E8_AGENCIA) + RTRIM(E8_CONTA)
			cSq2 += "   ,DtSalat			= CONVERT( DATE , E8_DTSALAT)	
			cSq2 += "   ,VlSalatua		    = ISNULL( E8_SALATUA , 0 )
			cSq2 += " FROM SE8" + aEmpresas[nX] + " SE8 "
			cSq2 += " WHERE SE8.D_E_L_E_T_=' '
			cSq2 += "   AND RTRIM(E8_BANCO) + RTRIM(E8_AGENCIA) + RTRIM(E8_CONTA) = '"+aChave[nJ][1]+"'
			cSq2 += " 	AND E8_DTSALAT = '"+aChave[nJ][2]+"'

		Next nJ

		If ( Select( "QRY" ) <> 0 )
			dbSelectArea ( "QRY" )
			dbCloseArea ()
		Endif

		dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	Next

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Banco"     			,"QRY->Id_Banco" 			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Agencia"  	 		,"QRY->Id_Agencia"  		,"@!",05,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ContaCorrente"  		,"QRY->Id_ContaCorrente" 	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Chave" 		 		,"QRY->Id_Chave"		 	,"@!",20,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtSalat"     			,"QRY->DtSalat"  		 	,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"VlSalatua"   			,"QRY->VlSalatua"  			,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return()
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSB2(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftEstoqueAtual"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " Select
		cSq2 += "   Id_Empresa		  = '1'
		cSq2 += "  ,DescProduto		  = Rtrim(SB1.B1_DESC)
		cSq2 += "  ,Id_Filial		  = B2_FILIAL
		cSq2 += "  ,Id_ProdutoUsar	  = B2_FILIAL+B2_COD
		cSq2 += "  ,Id_Produto		  = B2_COD
		cSq2 += "  ,Id_Armazem	   	  = B2_LOCAL 
		cSq2 += "  ,SaldoAtual        = B2_QATU    
		cSq2 += "  ,VlrValorFinal	  = B2_VFIM1 
		cSq2 += "  ,VlrSaldoAtual	  = B2_VATU1
		cSq2 += "  ,VlrCustoUnitario1 = B2_CM1
		cSq2 += "  FROM SB2" + aEmpresas[nX] + " SB2 "
		cSq2 += "  INNER JOIN SB1" + aEmpresas[nX] + " SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_='' "
		cSq2 += "  WHERE SB2.D_E_L_E_T_=' '  AND B2_QATU <> 0 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescProduto"     		,"QRY->DescProduto"			,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Produto"     		,"QRY->Id_Produto" 			,"@!",55,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Armazem"  	 		,"QRY->Id_Armazem"  		,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"SaldoAtual"     		,"QRY->SaldoAtual"   		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrValorFinal"     		,"QRY->VlrValorFinal"   	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrSaldoAtual"   		,"QRY->VlrSaldoAtual"  		,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrCustoUnitario1" 		,"QRY->VlrCustoUnitario1"  	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"T    "      			,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )
	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSB1(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimProdutos"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " SELECT
		cSq2 += "  Id_Empresa		 = '1',
		cSq2 += "  Id_Filial		 = B1_FILIAL,
		cSq2 += "  Id_Produto		 = Rtrim(b1.B1_COD),
		cSq2 += "  DescProduto		 = Rtrim(b1.B1_DESC),
		cSq2 += "  TipoProduto		 = Rtrim(b1.B1_TIPO),
		cSq2 += "  unidade			 = Rtrim(b1.B1_UM),
		cSq2 += "  Id_GrupoProduto   = Rtrim(b1.B1_GRUPO),
		cSq2 += "  GrupoProduto	     = Rtrim(bm.BM_DESC),
		cSq2 += "  Id_Armazem    	 = B1_LOCPAD,
		cSq2 += "  UltimoPrecocompra = B1_UPRC,
		cSq2 += "  Ultimodatacompra  = convert(date,B1_UCOM)
		cSq2 += "  FROM SB1"+ aEmpresas[nX] +" b1 
		cSq2 += "  LEFT JOIN SBM"+ aEmpresas[nX] +"  bm On b1.B1_FILIAL	= bm.BM_FILIAL And b1.B1_GRUPO	= bm.BM_GRUPO AND BM.D_E_L_E_T_ =' '
		cSq2 += "  WHERE b1.D_E_L_E_T_=''

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Produto"     		,"QRY->Id_Produto" 			,"@!",55,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescProduto"  			,"QRY->DescProduto"  		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoProduto"     		,"QRY->TipoProduto"   		,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"unidade"     			,"QRY->unidade"   			,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_GrupoProduto"   		,"QRY->Id_GrupoProduto"  	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"GrupoProduto" 			,"QRY->GrupoProduto"   		,"@!",100,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Armazem"  	 		,"QRY->Id_Armazem"   		,"@!",3,0,"","","C","TEM","R"})
	aadd(aHeader, {"Ultimodatacompra"   	,"QRY->Ultimodatacompra" 	,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )
	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSA2(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimFornecedores"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF
		cSq2 += " Select
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= A2.A2_FILIAL,
		cSq2 += "  Id_FornecUsar		= Rtrim(A2.A2_COD)+Rtrim(A2.A2_LOJA),
		cSq2 += "  Id_Fornece			= Rtrim(A2.A2_COD),
		cSq2 += "  Id_Loja				= Rtrim(A2.A2_LOJA),
		cSq2 += "  NomeFornece			= Rtrim(A2.A2_NOME),
		cSq2 += "  NReduz				= Rtrim(A2.A2_NREDUZ),
		cSq2 += "  Tipo					= Rtrim(A2_TIPO),
		cSq2 += "  Id_Municipio			= Rtrim(A2.A2_COD_MUN),
		cSq2 += "  Municipio			= Rtrim(A2.A2_MUN),
		cSq2 += "  Estado				= Rtrim(A2.A2_EST),
		cSq2 += "  Cnpj					= Rtrim(A2.A2_CGC),
		//cSq2 += "  TipoPessoa			= Rtrim(A2.A2_CGC),
		cSq2 += "  case A2.A2_EST  	         
		cSq2 += "  when'AC'then 'Acre'          
		cSq2 += "  when'AL'then 'Alagoas'          
		cSq2 += "  when'AP'then 'Amapa'          
		cSq2 += "  when'AM'then 'Amazonas'          
		cSq2 += "  when'BA'then 'Bahia'          
		cSq2 += "  when'CE'then 'Ceara'          
		cSq2 += "  when'DF'then 'Distrito Federal'          
		cSq2 += "  when'ES'then 'Espirito Santo'          
		cSq2 += "  when'GO'then 'Goias'          
		cSq2 += "  when'MA'then 'Maranhao'          
		cSq2 += "  when'MT'then 'Mato Grosso'          
		cSq2 += "  when'MS'then 'Mato Grosso do Sul'          
		cSq2 += "  when'MG'then 'Minas Gerais'          
		cSq2 += "  when'PA'then 'Para'          
		cSq2 += "  when'PB'then 'Paraiba'          
		cSq2 += "  when'PR'then 'Parana'          
		cSq2 += "  when'PE'then 'Pernambuco'          
		cSq2 += "  when'PI'then 'Piaui'          
		cSq2 += "  when'RJ'then 'Rio de Janeiro'          
		cSq2 += "  when'RN'then 'Rio Grande do Norte'          
		cSq2 += "  when'RS'then 'Rio Grande do Sul'          
		cSq2 += "  when'RO'then 'Rondonia'          
		cSq2 += "  when'RR'then 'Roraima'          
		cSq2 += "  when'SC'then 'Santa Catarina'          
		cSq2 += "  when'SP'then 'Sao Paulo'          
		cSq2 += "  when'SE'then 'Sergipe'          
		cSq2 += "  when'TO'then 'Tocantins'          
		cSq2 += "  END  as Estado
		cSq2 += "  From SA2"+ aEmpresas[nX] +" A2 (NOLOCK)
		cSq2 += "  Where A2.D_E_L_E_T_ = '' 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_FornecUsar" 	    	,"QRY->Id_FornecUsar" 		,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Fornece"     		,"QRY->Id_Fornece" 			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Loja"   				,"QRY->Id_Loja"  			,"@!",04,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomeFornece"     		,"QRY->NomeFornece"   		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"NReduz"     			,"QRY->NReduz"   			,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"Tipo"     				,"QRY->Tipo"   				,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Municipio"     		,"QRY->Id_Municipio"   		,"@!",5,0,"","","C","TEM","R"})
	aadd(aHeader, {"Municipio"     			,"QRY->Municipio"   		,"@!",100,0,"","","C","TEM","R"})
	aadd(aHeader, {"Estado"     			,"QRY->Estado"   			,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"Cnpj"     				,"QRY->Cnpj"   				,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSA1(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimClientes"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " Select
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= A1.A1_FILIAL,
		cSq2 += "  Id_ClientUsar	    = RTRIM(A1.A1_COD)+RTRIM(A1.A1_LOJA),
		cSq2 += "  Id_Cliente			= Rtrim(A1.A1_COD),
		cSq2 += "  Id_Loja				= Rtrim(A1.A1_LOJA),
		cSq2 += "  NomeCliente			= Rtrim(A1.A1_NOME),
		cSq2 += "  Pessoa				= Rtrim(A1_PESSOA),
		cSq2 += "  NReduz				= Rtrim(A1.A1_NREDUZ),
		cSq2 += "  Tipo					= Rtrim(A1_TIPO),
		cSq2 += "  Id_Municipio			= Rtrim(A1.A1_COD_MUN),
		cSq2 += "  Municipio			= Rtrim(A1.A1_MUN),
		cSq2 += "  Estado				= Rtrim(A1.A1_EST),
		cSq2 += "  Cnpj					= Rtrim(A1.A1_CGC),
		cSq2 += "  Id_Vendedor			= Rtrim(A1.A1_VEND),
		cSq2 += "  TipoPessoa			= CASE WHEN A1_TPESSOA = 'EP' THEN 'EMPRESA PUBLICA'		
		cSq2 += "							   WHEN A1_TPESSOA = 'CI' THEN 'COMERCIO/INDUSTRIA'
		cSq2 += "							   WHEN A1_TPESSOA = 'PF' THEN 'PESSOA FISICA'
		cSq2 += "							   WHEN A1_TPESSOA = 'OS' THEN 'PRESTACAO DE SERVICO' END ,
		cSq2 += "  Id_pais				= A1_PAIS,
		cSq2 += "  NomePais				= RTRIM(YA_DESCR),
		cSq2 += "  case A1.A1_EST  	         
		cSq2 += "  when'AC'then 'Acre'          
		cSq2 += "  when'AL'then 'Alagoas'          
		cSq2 += "  when'AP'then 'Amapa'          
		cSq2 += "  when'AM'then 'Amazonas'          
		cSq2 += "  when'BA'then 'Bahia'          
		cSq2 += "  when'CE'then 'Ceara'          
		cSq2 += "  when'DF'then 'Distrito Federal'          
		cSq2 += "  when'ES'then 'Espirito Santo'          
		cSq2 += "  when'GO'then 'Goias'          
		cSq2 += "  when'MA'then 'Maranhao'          
		cSq2 += "  when'MT'then 'Mato Grosso'          
		cSq2 += "  when'MS'then 'Mato Grosso do Sul'          
		cSq2 += "  when'MG'then 'Minas Gerais'          
		cSq2 += "  when'PA'then 'Para'          
		cSq2 += "  when'PB'then 'Paraiba'          
		cSq2 += "  when'PR'then 'Parana'          
		cSq2 += "  when'PE'then 'Pernambuco'          
		cSq2 += "  when'PI'then 'Piaui'          
		cSq2 += "  when'RJ'then 'Rio de Janeiro'          
		cSq2 += "  when'RN'then 'Rio Grande do Norte'          
		cSq2 += "  when'RS'then 'Rio Grande do Sul'          
		cSq2 += "  when'RO'then 'Rondonia'          
		cSq2 += "  when'RR'then 'Roraima'          
		cSq2 += "  when'SC'then 'Santa Catarina'          
		cSq2 += "  when'SP'then 'Sao Paulo'          
		cSq2 += "  when'SE'then 'Sergipe'          
		cSq2 += "  when'TO'then 'Tocantins'          
		cSq2 += "  END  as Estado
		cSq2 += "  From SA1"+ aEmpresas[nX] +" A1 (NOLOCK)
		cSq2 += "  LEFT JOIN SYA"+ aEmpresas[nX] +" SY ON A1_PAIS=SY.YA_CODGI
		cSq2 += "  Where A1.D_E_L_E_T_ = '' 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClientUsar"    	 	,"QRY->Id_ClientUsar" 		,"@!",20,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cliente"     		,"QRY->Id_Cliente" 			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Loja"   				,"QRY->Id_Loja"  			,"@!",4,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomeCliente"     		,"QRY->NomeCliente"   		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"Pessoa"					,"QRY->Pessoa" 				,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"NReduz"     			,"QRY->NReduz"   			,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"Tipo"     				,"QRY->Tipo"   				,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Municipio"     		,"QRY->Id_Municipio"   		,"@!",5,0,"","","C","TEM","R"})
	aadd(aHeader, {"Municipio"     			,"QRY->Municipio"   		,"@!",100,0,"","","C","TEM","R"})
	aadd(aHeader, {"Estado"     			,"QRY->Estado"   			,"@!",2,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoPessoa"				,"QRY->TipoPessoa" 			,"@!",55,0,"","","C","TEM","R"})
	aadd(aHeader, {"Cnpj"     				,"QRY->Cnpj"   				,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Vendedor"     		,"QRY->Id_Vendedor"   		,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Pais"     			,"QRY->Id_Pais"   			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomePais"     			,"QRY->NomePais"   			,"@!",60,0,"","","C","TEM","R"})
	aadd(aHeader, {"T   "      				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )
	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSED(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimNaturezas"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " Select
		cSq2 += "  	 Id_Empresa		= '1'
		cSq2 += "  	,Id_Filial		= ED_FILIAL
		cSq2 += "  	,Id_Natureza	= Rtrim(ED_CODIGO)
		cSq2 += "  	,DescNatureza	= Rtrim(ED_DESCRIC)
		cSq2 += "  	,Id_Formato     = CASE WHEN ED_COND ='R' THEN '2' ELSE '3' END 
		cSq2 += "  	,Condicao       = Rtrim(ED_COND)
		cSq2 += "  	From SED"+ aEmpresas[nX] +" SED
		cSq2 += "	Where D_E_L_E_T_ = ' '

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif


	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Natureza"     		,"QRY->Id_Natureza" 		,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"DescNatureza"   		,"QRY->DescNatureza"  		,"@!",255,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Formato"     		,"QRY->Id_Formato"   		,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"Condicao"				,"QRY->Condicao" 			,"@!",1,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSA3(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "dimVendedores"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " Select
		cSq2 += "  Id_Empresa			= '1',
		cSq2 += "  Id_Filial			= A3_FILIAL,
		cSq2 += "  Id_Vendedor			= Rtrim(A3_COD),
		cSq2 += "  Vendedor			    = Rtrim(A3_NOME),
		cSq2 += "  Cnpj				    = Rtrim(A3_CGC),
		cSq2 += "  Comissao			    = A3_COMIS * (0.001),
		cSq2 += "  Equipe               = Rtrim(A3_GRPREP),
		cSq2 += "  SupervisorVendedor	= (SELECT TOP 1 A3_NOME FROM "+RetSqlName("SA3")+" A3S  WHERE A3S.A3_COD = SA3.A3_SUPER ) ,
		cSq2 += "  Id_Gerente			= SA3.A3_GEREN,
		cSq2 += "  GerenteVendedor		= (SELECT TOP 1 A3_NOME FROM "+RetSqlName("SA3")+" A3S  WHERE A3S.A3_COD = SA3.A3_GEREN ) ,
		cSq2 += "  TipoVendedor		    = Rtrim (A3_TIPVEND) 
		cSq2 += "  From SA3"+ aEmpresas[nX] +" SA3
		cSq2 += "  Where SA3.D_E_L_E_T_ = ' ' 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif


	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Vendedor"     		,"QRY->Id_Vendedor" 		,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Vendedor"     			,"QRY->Vendedor"  			,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"Cnpj"     				,"QRY->Cnpj"    			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Comissao" 				,"QRY->Comissao"   		 	,"@E 999,999,999.99",12,2,"","","N","TEM","R"})
	aadd(aHeader, {"Equipe"     			,"QRY->Equipe"   			,"@!",14,2,"","","C","TEM","R"})
	aadd(aHeader, {"SupervisorVendedor"		,"QRY->SupervisorVendedor" 	,"@!",14,2,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Gerente"   			,"QRY->Id_Gerente"			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"GerenteVendedor" 		,"QRY->GerenteVendedor"    	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"TipoVendedor"   	  	,"QRY->TipoVendedor"    	,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )
	// Chamada da função de conversão para a planilha
	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaCAR(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftCarteira"
	PRIVATE aHeader := {}

	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF

		cSq2 += " 		SELECT
		cSq2 += " 		 Id_Empresa			= '1'					 		
		cSq2 += " 		,Id_Filial			= E1_FILIAL	 		
		cSq2 += " 		,Prefixo			= RTRIM(E1_PREFIXO) 		
		cSq2 += " 		,Documento  		= RTRIM(E1_NUM)   		
		cSq2 += " 		,Parcela			= RTRIM(E1_PARCELA)  		
		cSq2 += " 		,CliForUsar		    = RTRIM(E1_CLIENTE)+RTRIM(E1_LOJA) 		
		cSq2 += " 		,CliFor			    = RTRIM(E1_CLIENTE)  		
		cSq2 += " 		,RazaoSocial		= RTRIM(A1_NOME)		
		cSq2 += " 		,NomeReduz			= RTRIM(A1_NREDUZ) 		
		cSq2 += " 		,Loja				= RTRIM(E1_LOJA) 	
		cSq2 += " 		,Tipo      			= RTRIM(E1_TIPO)            		
		cSq2 += " 		,Id_Natureza		= RTRIM(E1_NATUREZ)     		
		cSq2 += " 		,DtEmissao          = CONVERT(DATE,E1_EMISSAO)   		
		cSq2 += " 		,DtVencimentoReal   = CONVERT(DATE,E1_VENCREA)  		
		cSq2 += " 		,VlrTitulo          = ISNULL(E1_VALOR,0) 		
		cSq2 += " 		,VlrSaldo	        = ISNULL(E1_SALDO,0) 		
		cSq2 += " 		,TipoCarteira		= 'R' 		
		cSq2 += " 		FROM  SE1"+ aEmpresas[nX] +" SE1		
		cSq2 += " 		INNER JOIN SA1"+ aEmpresas[nX] +" SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA 	AND SA1.D_E_L_E_T_= ' '	
		cSq2 += " 		WHERE 		SE1.D_E_L_E_T_= ' ' AND E1_SALDO > 0 


		cSq2 += " 		UNION ALL

		cSq2 += " 		SELECT  		 
		cSq2 += " 		Id_Empresa			='1'					 		
		cSq2 += " 		,Id_Filial			= E2_FILIAL	 		
		cSq2 += " 		,Prefixo			= RTRIM(E2_PREFIXO) 		
		cSq2 += " 		,Documento  		= RTRIM(E2_NUM)   		
		cSq2 += " 		,Parcela			= RTRIM(E2_PARCELA)  		
		cSq2 += " 		,CliForUsar		    = RTRIM(E2_FORNECE)+RTRIM(E2_LOJA)  		
		cSq2 += " 		,CliFor			    = RTRIM(E2_FORNECE) 		
		cSq2 += " 		,RazaoSocial		= RTRIM(A2_NOME)		
		cSq2 += " 		,NomeReduz			= RTRIM(A2_NREDUZ) 		
		cSq2 += " 		,Loja				= RTRIM(E2_LOJA)  		
		cSq2 += " 		,Tipo      			= RTRIM(E2_TIPO)            		
		cSq2 += " 		,Id_Natureza		= RTRIM(E2_NATUREZ)     		
		cSq2 += " 		,DtEmissao          = CONVERT(DATE,E2_EMISSAO)   		
		cSq2 += " 		,DtVencimentoReal   = CONVERT(DATE,E2_VENCREA)  		
		cSq2 += " 		,VlrTitulo          = ISNULL(E2_VALOR,0) 		
		cSq2 += " 		,VlrSaldo	        = ISNULL(E2_SALDO,0) 		
		cSq2 += " 		,TipoCarteira		= 'P'
		cSq2 += " 		FROM  SE2"+ aEmpresas[nX] +" SE2		
		cSq2 += " 		INNER JOIN SA2"+ aEmpresas[nX] +" SA2 ON SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA AND SA2.D_E_L_E_T_= ' '	
		cSq2 += " 		WHERE 		SE2.D_E_L_E_T_= ' ' AND E2_SALDO > 0 

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif


	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Prefixo"      			,"QRY->PREFIXO" 			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Documento"     			,"QRY->DOCUMENTO"  			,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"Parcela"     			,"QRY->PARCELA"    			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Tipo" 					,"QRY->TIPO"   			 	,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Vlrtitulo"     			,"QRY->VLRTITULO"   		,"@E 999,999,999.99",14,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrSaldo"      			,"QRY->VLRSALDO" 			,"@E 999,999,999.99",14,2,"","","N","TEM","R"})
	aadd(aHeader, {"Id_Natureza"   			,"QRY->ID_NATUREZA"			,"@!",15,0,"","","C","TEM","R"})
	aadd(aHeader, {"CliForUsar"				,"QRY->CliForUsar"  		,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"CliFor	" 				,"QRY->CliFor" 		   		,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"RAZAOSOCIAL" 			,"QRY->RAZAOSOCIAL" 	   	,"@!",120,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomeReduz" 				,"QRY->NomeReduz" 	 	  	,"@!",120,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtEmissao"   		  	,"QRY->DTEMISSAO"    		,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"DtVencimentoReal"     	,"QRY->DTVENCIMENTOREAL"   	,"@!",10,0,"","","D","TEM","R"})
	//aadd(aHeader, {"DtBaixa"  			   	,"QRY->DTBAIXA" 		   	,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"Loja"      				,"QRY->LOJA"	          	,"@!",04,0,"","","C","TEM","R"}) 
	aadd(aHeader, {"TipoCarteira"  			,"QRY->TipoCarteira"	   	,"@!",01,0,"","","C","TEM","R"}) 
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf


Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaSE1(lSched)

	local cArqTrb1	:= CriaTrab(NIL,.F.)
	local aStru     := {}
	Local cSq2 		:= ""

	PRIVATE cArquivo:= "ftTitulosReceber"
	PRIVATE aHeader := {}
	cSq2 := ""
	For nX:= 1 to len(aEmpresas)

		IF cSq2 <> ""
			cSq2 += "UNION ALL "
		ENDIF
		cSq2 += " SELECT 
		cSq2 += " 		 Id_Empresa			= '1'					
		cSq2 += " 		,Id_Filial			=E1_FILIAL	
		cSq2 += " 		,Prefixo			=RTRIM(E1_PREFIXO)
		cSq2 += " 		,Documento  		=RTRIM(E1_NUM)  
		cSq2 += " 		,Parcela			=RTRIM(E1_PARCELA) 
		cSq2 += " 		,Id_ClientUsar	    =RTRIM(E1_CLIENTE)+RTRIM(E1_LOJA)
		cSq2 += " 		,Id_Cliente		    =RTRIM(E1_CLIENTE) 
		cSq2 += " 		,Loja				=RTRIM(E1_LOJA) 
		cSq2 += "		,RazaoSocial		=RTRIM(A1_NOME)
		cSq2 += "		,NomeReduz			=RTRIM(A1_NREDUZ)
		cSq2 += " 		,Tipo      			=RTRIM(E1_TIPO)           
		cSq2 += " 		,Id_Natureza		=RTRIM(E1_NATUREZ)    
		cSq2 += " 		,DtEmissao          =CONVERT(DATE,E1_EMISSAO)  
		cSq2 += " 		,DtVencimentoReal   =CONVERT(DATE,E1_VENCREA) 
		cSq2 += " 		,VlrTitulo          =ISNULL(E1_VALOR,0)
		cSq2 += " 		,VlrSaldo	        =ISNULL(E1_SALDO,0)
		cSq2 += " 		,DtBaixa			=CONVERT(DATE,E1_BAIXA)
		cSq2 += " 		FROM  SE1"+ aEmpresas[nX] +" SE1
		cSq2 += "		INNER JOIN SA1"+ aEmpresas[nX] +" SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA
		cSq2 += " 		WHERE
		cSq2 += " 		SE1.D_E_L_E_T_= ' ' AND E1_SALDO > 0 AND E1_TIPO NOT IN ( 'RA' )

	Next

	If ( Select( "QRY" ) <> 0 )
		dbSelectArea ( "QRY" )
		dbCloseArea ()
	Endif


	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cSq2 ), "QRY" , .F., .T. )

	QRY->(dbGoTop())

	aadd(aHeader, {"Id_Empresa"    			,"QRY->ID_EMPRESA" 			,"@!",01,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Filial"     			,"QRY->ID_FILIAL" 			,"@!",02,0,"","","C","TEM","R"})
	aadd(aHeader, {"Prefixo"      			,"QRY->PREFIXO" 			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Documento"     			,"QRY->DOCUMENTO"  			,"@!",09,0,"","","C","TEM","R"})
	aadd(aHeader, {"Parcela"     			,"QRY->PARCELA"    			,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Tipo" 					,"QRY->TIPO"   			 	,"@!",03,0,"","","C","TEM","R"})
	aadd(aHeader, {"Vlrtitulo"     			,"QRY->VLRTITULO"   		,"@E 999,999,999.99",14,2,"","","N","TEM","R"})
	aadd(aHeader, {"VlrSaldo"      			,"QRY->VLRSALDO" 			,"@E 999,999,999.99",14,2,"","","N","TEM","R"})
	aadd(aHeader, {"Id_Natureza"   			,"QRY->ID_NATUREZA"			,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_ClientUsar" 			,"QRY->Id_ClientUsar"	   	,"@!",14,0,"","","C","TEM","R"})
	aadd(aHeader, {"Id_Cliente" 			,"QRY->Id_Cliente" 		   	,"@!",10,0,"","","C","TEM","R"})
	aadd(aHeader, {"RAZAOSOCIAL" 			,"QRY->RAZAOSOCIAL" 	   	,"@!",120,0,"","","C","TEM","R"})
	aadd(aHeader, {"NomeReduz" 				,"QRY->NomeReduz" 	 	  	,"@!",120,0,"","","C","TEM","R"})
	aadd(aHeader, {"DtEmissao"   		  	,"QRY->DTEMISSAO"    		,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"DtVencimentoReal"     	,"QRY->DTVENCIMENTOREAL"   	,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"DtBaixa"  			   	,"QRY->DTBAIXA" 		   	,"@!",10,0,"","","D","TEM","R"})
	aadd(aHeader, {"Loja"      				,"QRY->LOJA"	          	,"@!",04,0,"","","C","TEM","R"}) 
	aadd(aHeader, {"T    "     				,"FIM"           			,"@!",02,2,"","","F","TEM","R"}) // COLUNA DE CONTROLE DO ENCHOICE ( DELETADO OU NÃO )

	// Chamada da função de conversão para a planilha
	If lSched
		GeraCSV( "QRY" )
	Else
		MsAguarde({||GeraCSV( "QRY" )},"Aguarde","Gerando Planilha",.F.)
	EndIf

Return
/*/{Protheus.doc} CEXPBID3
// Fabrica de Software Fabritec -> Luiz Ferreira
// Programa gerador de dados para conexão com Power Bi Microsoft
// Pasta padrão que os dados são salvos D:\TEMP
@since 09/05/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function geraCSV(_cAlias)              

	local cDirDocs  := MsDocPath()
	Local cPath     := "C:\TEMP\"
	Local cCrLf     := Chr(13) + Chr(10)
	Local _cArq     := ""

	Local nX
	Local nHandle

	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

	If nHandle > 0

		// Grava o cabecalho do arquivo
		aEval(aHeader, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aHeader), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha

		(_cAlias)->(dbgotop())
		while (_cAlias)->(!eof())

			for _ni := 1 to len(aHeader)

				_uValor := ""

				If aHeader[_ni,8] != "F"
					if aHeader[_ni,8] == "D" // Trata campos data
						_uValor := dtoc(&(aHeader[_ni,2]))
					elseif aHeader[_ni,8] == "N" // Trata campos numericos
						_uValor := transform( &(aHeader[_ni,2]) , aHeader[_ni,3] )
					elseif aHeader[_ni,8] == "C" // Trata campos caracter
						If ALLTRIM( FUNNAME() ) $ "MontaCAR|MontaSA6|MontaSE8|MontaSED" //.AND. ALLTRIM( FUNNAME() ) == "MontaSE8"  
							_uValor :=  "'" + &(aHeader[_ni,2])
						Else
							_uValor :=  &(aHeader[_ni,2])
						EndIf
					endif

					if _ni <> len(aHeader)
						fWrite(nHandle, _uValor + ";" )
					endif
				EndIf

			next _ni

			fWrite(nHandle, cCrLf )

			(_cAlias)->(dbskip())

		enddo

		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )

	Else
		MsgAlert("Falha na criação do arquivo")
	Endif

	(_cAlias)->(dbclearfil())

	Return

return