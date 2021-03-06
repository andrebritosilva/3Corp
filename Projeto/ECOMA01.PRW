#INCLUDE "Rwmake.ch"
#INCLUDE "Topconn.ch"
/*
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    � ECOMA01  � Valida��o no n�mero da nota fiscal de entrada                ���
���             �          � 1. Preencher o n�mero da nota fiscal com zeros � esquerda    ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 21.06.07 � Anderson Rodrigues                                           ���
�����������������������������������������������������������������������������������������͹��
��� Produ��o    � ??.??.?? � Ignorado                                                     ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
*/
User Function ECOMA01()

Local cNum	:=Alltrim(cNFiscal)
Local nTam	:=TamSx3("F1_DOC")[1]
Local lRet  := .T.
Local _cSer :=Alltrim(cSerie)                      

If INCLUI
	If Len(cNum) < nTam
		cNFiscal:=Strzero(0,nTam-Len(cNum))+cNum // preenche com zeros a esquerda do numero do titulo.
	EndIf
	
	
	DbSelectArea('SF1')
	DbSetOrder(1)
	If(MsSeek(xFilial('SF1') + cNFiscal))
		Alert(" O numero: "+ cNFiscal +" j� existe!")
	EndIf
	
Endif

Return(lRet)