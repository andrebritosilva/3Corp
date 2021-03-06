/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAAVCRPR    �Autor  �Eletromega        � Data �  04/27/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada pertence � rotina de avaliza��o de   ���
���			 � cr�dito de clientes, MaAvalCred() � FATXFUN(). Ele permite ���
���			 � que, ap�s a avalia��o padr�o do sistema, o usu�rio possa   ���
���			 � fazer a sua pr�pria. (Chamado por item)                    ���
���          � Bloquear a libera�a de credito para pedidos com condi�ao   ���
���          � de pagamento: A VISTA E DEPOSITO BANCARIO                  ���
�������������������������������������������������������������������������͹��
��� Parametros� Argumento												  ���
��� PARAMIXB : Array 									                  ���
��� ParamIxb[1]=C�digo do cliente									      ���
��� ParamIxb[2]=C�digo da filial									      ���
��� ParamIxb[3]=Valor da venda									          ���
��� ParamIxb[4]=Moeda da venda									          ���
��� ParamIxb[5]=Considera acumulados de Pedido de Venda do SA1			  ���						 
��� ParamIxb[6]=Tipo de cr�dito (�L� - C�digo cliente + Filial;           ���
���								 �C� - c�digo do cliente)				  ���
��� ParamIxb[7]=Indica se o credito ser� liberado ( L�gico )              ���
��� ParamIxb[8]=Indica o c�digo de bloqueio do credito ( Caracter )		  ���							                         
���          �                            								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Retorno   � L�gico 													  ���
��� .T. - cr�dito aprovado                                                ���
��� .F. - cr�dito n�o aprovado.                                           ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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