#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103IPC  �Autor  �iVan Oliveira - Ethosx  � Data � 02/04/20���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � 3Corp                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT103IPC()

Local _nLin  := ParamIXB[1]

Default _nLin := 0

if Type('aHeader') == 'A' .and. Type('acols') == 'A'.and. _nLin#0

	_nPosProd := aScan(aHeader,{|x| Alltrim(x[02]) == 'D1_COD'})
	_nPosDesc := aScan(aHeader,{|x| Alltrim(x[02]) == 'D1_X_DESCR'})

	// Encontrado os campos no Aheader, gatilhar descri��o do Produto.
	if _nPosDesc #0 .and. _nPosProd #0

		_cCodProd := acols[_nLin][_nPosProd]
		acols[_nLin][_nPosDesc] := GetAdvFVal("SB1", "B1_DESC", FwxFilial("SB1") + _cCodProd , 1, "", .T.)

	Endif

Endif

Return  