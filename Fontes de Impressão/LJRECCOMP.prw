/*/{Protheus.doc} LJRECCOMP
//TODO Recibo de pagamento impresso em 2 vias ao final do recebimento - LJXREC
@author Gabriel - TOTVSPB
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function LJRECCOMP

Local aAreaSA1 := SA1->(GetArea())
Local aAreaUF0 := UF0->(GetArea())
Local aAreaUF2 := UF2->(GetArea())
Local aAreaSLG := SLG->(GetArea())

#DEFINE LARG 48
#DEFINE ENTER CHR(13)+CHR(10)  

Local cNOME 		:= ""
Local cEND1			:= ""
Local cEND2			:= ""
Local cTEL 			:= ""
Local aTitulo 		:= PARAMIXB[4]
Local aForma		:= PARAMIXB[5]
Local cMvSimb12 	:= "R$"
Local nTotal 		:= 0
Local nLiq			:= 0
Local cPlano		:= "N/A"
Local cContrato		:= "N/A"
Local cOperador		:= AllTrim(UsrRetName ( RetCodUsr ( ) ))
Local nCont			:= 0
Local Nt			:= 0
Local cMsgD 		:= ""
Local lPaCupom		:= GetMv("MV_XCUPOM")

dbSelectArea("SA1")
SA1->(MsSeek(xFilial("SA1")+aTitulo[1,13]+aTitulo[1,14]))

DbSelectArea("UF2")
If UF2->(MsSeek(xFilial("UF2")+aTitulo[1,3]))
	cContrato := UF2->UF2_CODIGO
EndIf										

DbSelectArea("UF0")
If UF0->(MsSeek(xFilial("UF0")+UF2->UF2_PLANO))
	cPlano := UF2->UF2_PLANO + " - " + AllTrim(UF0->UF0_DESCRI) 
EndIf

DbSelectArea("SLG")
SLG->(MsSeek(xFilial("SLG") + cEstacao))

//dbSelectArea("SM0")
//SM0->(DbSeek(FWCodFil()))

cNOME 	:= SubStr(AllTrim(SM0->M0_NOMECOM),1,LARG)
cEND1 	:= SubStr(AllTrim(SM0->M0_ENDCOB) + ", " + AllTrim(SM0->M0_COMPCOB),1,LARG)
cEND2 	:= SubStr(AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB) + " - " - AllTrim(SM0->M0_ESTCOB),1,LARG) 
cTEL 	:= AllTrim(SM0->M0_TEL)
 

//-------------CABEÇALHO------------------
cMsgComprovante :=  Replicate("-",LARG) 		+ ENTER
cMsgComprovante += 	PadC(cNOME,LARG) 			+ ENTER
cMsgComprovante += 	PadC(cEND1,LARG) 			+ ENTER
cMsgComprovante += 	PadC(cEND2,LARG) 			+ ENTER
cMsgComprovante += 	PadC(cTEL,LARG) 			+ ENTER
cMsgComprovante +=  Replicate("-",LARG) 		+ ENTER + ENTER
//-----------------FIM--------------------


//------------DADOS CLIENTE---------------
cMsgComprovante += 	PadC("Recibo de Pagamento",LARG) + ENTER + ENTER
cMsgComprovante += 	"Código: " + AllTrim(SA1->A1_COD) + Space(15) + "Contrato: " + cContrato + ENTER
cMsgComprovante += 	"Beneficiário: " + AllTrim(SA1->A1_NOME) + ENTER
cMsgComprovante += 	"Endereço: " + AllTrim(SA1->A1_END) + AllTrim(SA1->A1_COMPENT) + ENTER
cMsgComprovante += 	"Plano: " + cPlano + ENTER + ENTER

//-----------------FIM--------------------


//--------------TITULOS-------------------
cMsgComprovante += 	PadC("ITEM  "  + "TITULO           " + "VENCIMENTO     VALOR(R$)",LARG) +ENTER
For Nt := 1 To Len(aTitulo)
	
	nTotal += (aTitulo[Nt,06])
	nLiq   += (aTitulo[Nt,10])
	
	cMsgComprovante += " " + PadL(cValToChar(Nt),2,"0") +"   "+ aTitulo[Nt,03]+"/"+AllTrim(aTitulo[Nt,04]) +"     "+SubStr(MesExtenso( aTitulo[Nt,05] ),1,3) + "/" + AllTrim(cValToChar(Year(aTitulo[Nt,05]))) + Space(6);
	+ PadL(AllTrim(Transform(aTitulo[Nt,06],"@E 9,999.99")),8) + ENTER
	
Next Nt

If nTotal <> nLiq
	cMsgComprovante += ENTER + "Desconto: " + cMvSimb12 + " " + AllTrim(Transform(nTotal-nLiq,"@E 999,999,999.99"))
EndIf	
cMsgComprovante += ENTER + "T O T A L:" + Space(24) + cMvSimb12 + " " + AllTrim(Transform(nLiq,"@E 999,999,999.99")) + ENTER + ENTER
cMsgComprovante += 	"Forma(s) de Pagamento: " + ENTER

For nT:= 1 To Len(aForma) 
	cMsgComprovante += AllTrim(aForma[nT,3]) +" : " + PadL(AllTrim(Transform(aForma[Nt,2],"@E 9,999.99")),8) + ENTER
Next

cMsgComprovante += ENTER + ENTER

cMsgComprovante += 	"Data: " +  DTOC(Date()) + " - " +SubStr(Time(),1,5) + ENTER
cMsgComprovante += 	"Operador(a): " + UPPER(cOperador) + ENTER 
cMsgComprovante += 	"Caixa Local: " + SLG->LG_NOME + ENTER + ENTER 

//---------------FIM----------------------




//-------------RODAPE-------------------
cMsgComprovante += Replicate("-",LARG) + ENTER
cMsgComprovante += PadC("Anexar este recibo ao boleto de cobrança.",LARG) + ENTER
cMsgComprovante += PadC("Este cupom NÃO TEM valor fiscal.",LARG) + ENTER
cMsgComprovante += Replicate("-",LARG-1)
//--------------FIM---------------------

//Imprimi


IF lPaCupom  .And. tlpp.call('U_DESCONTO', SA1->A1_COD,cContrato)

IFRelGer( nHdlECF, cMsgComprovante, 2 )
//-------------CUPOM DE DESCONTO-------------------
cMsgD += Replicate("-",LARG) + ENTER
cMsgD += PadC("CLUBE DE BENEFÍCIOS ROSA MASTER",LARG) + ENTER
cMsgD += PadC("Autorização de desconto em parceiros.",LARG) + ENTER
cMsgD += 	"Beneficiário: " + AllTrim(SA1->A1_NOME) + ENTER
cMsgD += 	"Código Cliente: " + AllTrim(SA1->A1_COD) + Space(7) + "Contrato: " + cContrato + ENTER
cMsgD += 	"Plano: " + cPlano + ENTER + ENTER
cMsgD +=    "Status:" +  "AUTORIZADO" + ENTER
//cMsgD += "Status:" + IF (cContrato == "N/A", "NÃO AUTORIZADO", "AUTORIZADO") + ENTER
cMsgD += 	"Válido por 30 dias a partir desta data" + ENTER
cMsgD += "Data: " +  DTOC(Date()) + " - " +SubStr(Time(),1,5) + ENTER
cMsgD += "Dica: Desconto em toda rede de parceiros local" + ENTER
cMsgD += Replicate("-",LARG-1)
//--------------FIM---------------------

//Imprimi
IFRelGer(nHdlECF,cMsgD,1)

Else 

IFRelGer( nHdlECF, cMsgComprovante, 2 )

EndIF


//-------------SMARTPIX-------------------
For nCont:= 1 To Len(aForma) 	
	If AllTrim(aForma[nCont,3]) == "PI"
		U_CupomPix(aTitulo)
		Exit
	EndIf
Next

RestArea(aAreaSA1)
RestArea(aAreaUF0)
RestArea(aAreaUF2)
RestArea(aAreaSLG)				  
Return

//------------------------------------------------------------------------------
/*{Protheus.doc} CupomPix
PE chamado após a impressão do cupom e gravação das tabelas
É usado para impressão do cupom PIX
@param   	     
@author     Fábio Siqueira dos Santos
@version    P12
@since      03/11/2021
@return     Nil
/*/
//------------------------------------------------------------------------------
User Function CupomPix(aTitulo)
Local cCodAut   := ""
Local cBcoPIX   := GetMV("MV_XBCOPIX",,"001")
Local nCont		:= 0
Local aZPX		:= {}

//Primeiro gravo a qtde de ZPX de acordo com a qtde de títulos que foi usado
ZPX->(DbSetOrder(1)) //ZPX_FILIAL+ZPX_CODIGO
If ZPX->(DbSeek(xFilial("ZPX")+M->LQ_NUM))
	aAdd(aZPX,{ZPX->ZPX_FILIAL,ZPX->ZPX_CODIGO,ZPX->ZPX_TXID,ZPX->ZPX_CHAVE,ZPX->ZPX_VALOR,ZPX->ZPX_VLPIX,ZPX->ZPX_STATUS,ZPX->ZPX_DATA,ZPX->ZPX_CONCIL,ZPX->ZPX_PDV,ZPX->ZPX_HORA})
	For nCont := 1 To Len(aTitulo)
		If nCont == 1
			ZPX->(RecLock( "ZPX", .F. ))
				ZPX->ZPX_DOC	:= aTitulo[nCont,3] 
				ZPX->ZPX_SERIE	:= aTitulo[nCont,2]
				ZPX->ZPX_PARCEL	:= aTitulo[nCont,4]
				ZPX->ZPX_HORADC := ZPX->ZPX_HORA
				ZPX->ZPX_SITUA  := "00"
				ZPX->ZPX_CONCIL  := "1"
			ZPX->(MsUnlock())
		Else
			Sleep(2000)
			ZPX->(RecLock( "ZPX", .T. ))
				ZPX->ZPX_FILIAL := aZPX[1,1] 
				ZPX->ZPX_CODIGO := aZPX[1,2] 
				ZPX->ZPX_HORA   := Iif(SOMA1(SUBSTR(TIME(),7,2)) == "60",SubStr(Time(),1,3) + Soma1(SUBSTR(TIME(),4,2)) + ":00", SubStr(Time(),1,6) + SOMA1(SUBSTR(TIME(),7,2)))
				ZPX->ZPX_TXID   := aZPX[1,3] 
				ZPX->ZPX_CHAVE  := aZPX[1,4] 
				ZPX->ZPX_VALOR  := aZPX[1,5] 
				ZPX->ZPX_VLPIX  := aZPX[1,6] 
				ZPX->ZPX_STATUS := aZPX[1,7] 
				ZPX->ZPX_DATA   := aZPX[1,8] 
				ZPX->ZPX_CONCIL := aZPX[1,9] 
				ZPX->ZPX_PDV	:= aZPX[1,10] 
				ZPX->ZPX_DOC	:= aTitulo[nCont,3] 
				ZPX->ZPX_SERIE	:= aTitulo[nCont,2]
				ZPX->ZPX_PARCEL	:= aTitulo[nCont,4]
				ZPX->ZPX_HORADC := aZPX[1,11] 
				ZPX->ZPX_SITUA  := "00"
				ZPX->ZPX_CONCIL  := "1"
			ZPX->(MsUnlock())
		EndIf
	Next nCont
EndIf

For nCont := 1 To Len(aTitulo)
	ZPX->(DbSetOrder(4)) //ZPX_FILIAL+ZPX_PREFIXO+ZPX_DOC+ZPX_PARCELA   
	If ZPX->(DbSeek(xFilial("ZPX")+aTitulo[nCont,2]+aTitulo[nCont,3]+aTitulo[nCont,4]))
		If AllTrim(ZPX->ZPX_STATUS) == "CONCLUIDA"
			If cBcoPIX == "001"
				cCodAut := AllTrim(ZPX->ZPX_TXID)
			Else
				cCodAut := AllTrim(ZPX->ZPX_CHAVE)
			EndIf
								
		EndIf
		If !Empty(cCodAut)
			//Chama a rotina de impressão do PIX
			U_ImpPIX(cCodAut,aTitulo[nCont,2],aTitulo[nCont,3],aTitulo[nCont,4],aTitulo[nCont,6],aTitulo[nCont,20])
			//Exit
		EndIf
	EndIf
	
Next nCont
      
Return .T.

/*/{Protheus.doc} ImprimePIX
   Realiza a Impressão do comprovante
   @type  Function
   @author Fábio Siqueira dos Santos 
   @since 03/11/2021
   @version P12
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
User Function ImpPIX(cCodAut,cPrefixo,cNumTit,cParc,nValor,dDtVenc)
Local cMsg      := ""
Local cMsgVia   := ""
Local nVias     := 0
Local nCols     := Iif( !Empty(LjGetStation("LG_LARGCOL")), LjGetStation("LG_LARGCOL"), 40 )
Local cEOL      := chr(13)+chr(10)
Local cPicValor := PesqPict("SL4","L4_VALOR")//Picture de valor

cMsgVia := "V I A  C L I E N T E"

For nVias := 1 To 2

    cMsg := ""
    cMsg  += "<ce>"
    cMsg  += "<b>"
    cMsg  += cMsgVia + cEOL
    cMsg  += AllTrim(SM0->M0_FILIAL) + " - " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + cEOL
    cMsg  += " " + cEOL
    cMsg  += "COMPROVANTE PIX" + cEOL
    cMsg  += "</b>"
    cMsg  += "</ce>" 
    cMsg  += "" + cEOL
    cMsg  += "<b>Prefixo:</b> " + cPrefixo + "<b>Título:</b> " + cNumTit + "<b>Parcela:</b> " + cParc + cEOL
    cMsg  += "<b>Data:</b> " + Padl(DtoC(dDtVenc),14) + " "
    cMsg  += "<b>Hora:</b> " + Padl(Time(),12) + cEOL 
    cMsg  += "<b>Metodo de Pagamento:</b> " + Padl("PIX",7) + cEOL 
    cMsg  += "<b>Total:</b> " + "R$ " + AllTrim(Transform(nValor,cPicValor)) + cEOL 
    cMsg  += "<b>Autorização:</b> " + cCodAut + cEOL 
    cMsg  += " " + cEOL
    cMsg  += Replicate("-",nCols) + cEOL  

    STWManagReportPrint(cMsg,1)

    cMsgVia := "V I A  E S T A B E L E C I M E N T O"
Next


Return
