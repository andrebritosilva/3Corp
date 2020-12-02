/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAAVCRPR    ºAutor  ³Eletromega        º Data ³  04/27/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada pertence à rotina de avalização de   º±±
±±º			 ³ crédito de clientes, MaAvalCred() – FATXFUN(). Ele permite º±±
±±º			 ³ que, após a avaliação padrão do sistema, o usuário possa   º±±
±±º			 ³ fazer a sua própria. (Chamado por item)                    º±±
±±º          ³ Bloquear a liberaça de credito para pedidos com condiçao   º±±
±±º          ³ de pagamento: A VISTA E DEPOSITO BANCARIO                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros³ Argumento												  º±±
±±º PARAMIXB : Array 									                  º±±
±±º ParamIxb[1]=Código do cliente									      º±±
±±º ParamIxb[2]=Código da filial									      º±±
±±º ParamIxb[3]=Valor da venda									          º±±
±±º ParamIxb[4]=Moeda da venda									          º±±
±±º ParamIxb[5]=Considera acumulados de Pedido de Venda do SA1			  º±±						 
±±º ParamIxb[6]=Tipo de crédito (“L” - Código cliente + Filial;           º±±
±±º								 “C” - código do cliente)				  º±±
±±º ParamIxb[7]=Indica se o credito será liberado ( Lógico )              º±±
±±º ParamIxb[8]=Indica o código de bloqueio do credito ( Caracter )		  º±±							                         
±±º          ³                            								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ Lógico 													  º±±
±±º .T. - crédito aprovado                                                º±±
±±º .F. - crédito não aprovado.                                           º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      

User function MAAVCRPR()

	Local lRet := ParamIxb[7]  
	Local xLoc := SC9->(RECNO())
	
	If SC5->C5_XSTATUS== "04"
	
	 	lRet:= .T.
	
		SC9->(DbSetOrder(1))
		
		If SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM ) )
		
			While SC9->(!EOF()) .And. SC9->C9_PEDIDO == SC5->C5_NUM
			    
				SC9->(Reclock("SC9",.F.))
				SC9->C9_XBLQ:= "X"
				SC9->(MsUnLock())			
				
				SC9->(DbSkip())
			
			End
		
	
		EndIf
		SC9->(DbGoTo(xLoc))
	
	EndIf                                          

Return (lRet)