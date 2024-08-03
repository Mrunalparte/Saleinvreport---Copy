report 80119 "Sales Invoice Report"
{
    Caption = 'Sales Invoice GST Report New';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    // RDLCLayout = 'TaxInvoiceGST.rdl';
    RDLCLayout = 'TaxInvoiceGSTNew.rdl';

    dataset
    {
        #region [Sales Header]
        dataitem("Sales Header"; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(InvoiceNo; "No.") { }
            column(Order_No_; "Order No.") { }
            column(Customer_No_; "Sell-to Customer No.") { }
            column(Customer_Name; "Sell-to Customer Name") { }
            column(Sell_to_Address; "Sell-to Address") { }
            column(Sell_to_Address_2; "Sell-to Address 2") { }
            column(Sell_to_City; "Sell-to City") { }
            column(Document_Date; "Document Date") { }
            column(Post_Code; "Sell-to Post Code") { }
            column(LR_RR_No_; "LR/RR No.") { }
            column(LR_RR_Date; "LR/RR Date") { }
            column(Transport_Method; "Transport Method") { }
            column(Location_State_Code; "Location State Code") { }
            column(Customer_GST_Reg__No_; "Customer GST Reg. No.") { }
            column(Payment_Terms_Code; "Payment Terms Code") { }
            column(Vehicle_No_; "Vehicle No.") { }
            column(Agent_Code; "Shipping Agent Code") { }
            column(ACK_No_; "Acknowledgement No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Ship_to_Name; "Ship-to Name") { }
            column(Ship_to_Address; "Ship-to Address") { }
            column(Ship_to_Address_2; "Ship-to Address 2") { }
            column(Ship_to_City; "Ship-to City") { }
            column(Ship_Post_Code; "Ship-to Post Code") { }
            column(Ship_GST_Reg_No_; "Ship-to GST Reg. No.") { }
            column(CompanyBankAcNo; CompanyInfo."Bank Account No.") { }
            column(CompanyBank; CompanyInfo."Bank Name") { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyAddress2; CompanyInfo."Address 2") { }
            column(CompanyCity; CompanyInfo.City) { }
            column(CompanyCountry; CompanyInfo."Country/Region Code") { }
            column(CompanyCode; CompanyInfo."Post Code") { }
            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyNo; CompanyInfo."Phone No.") { }
            column(CompanyEmail; CompanyInfo."E-Mail") { }
            column(CompanyGST; CompanyInfo."GST Registration No.") { }
            column(CompanyPic; CompanyInfo.Picture) { }
            column(CompanyCIN; CompanyInfo."Registration No.") { }
            column(CompanySWCode; CompanyInfo."SWIFT Code") { }
            column(CustPanNo; CustPanNo) { }
            column(CustStateCode; CustStateCode) { }
            column(CustNo; CustNo) { }
            column(LocName; LocName) { }
            column(LocAdd; LocAdd) { }
            column(LocAdd2; LocAdd2) { }
            column(LocCity; LocCity) { }
            column(LocPostCode; LocPostCode) { }
            column(LocGst; LocGst) { }
            column(StateName; StateName) { }
            column(StateCode; StateCode) { }
            column(StaName; StaName) { }
            column(StaDes; StaDes) { }
            column(StaCode; StaCode) { }
            column(FromState; FromState) { }
            column(CompName; CompName) { }
            column(CompCode; CompCode) { }
            #endregion


            #region [Sales Line]
            dataitem("Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Sales Header";
                // DataItemTableView = sorting("Document No.", "Line No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Type = filter(<> " "));
                // UseTemporary = true;
                column(Line_No_; "Line No.") { }
                column(ItemCode; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }
                column(Amount; "Line Amount") { }
                column(HSN_SAC_Code; "HSN/SAC Code") { }
                column(GST_Group_Code; "GST Group Code") { }
                column(Discount; "Line Discount %") { }
                column(VAT__; "VAT %") { }
                column(GSTPer; GSTPer) { }
                column(CGSTPer; CGSTPer) { }
                column(SGSTPer; SGSTPer) { }
                column(IGSTPer; IGSTPer) { }
                column(NetAmt; NetAmt) { }
                column(CGSTAmt; CGSTAmt) { }
                column(SGSTAmt; SGSTAmt) { }
                column(IGSTAmt; IGSTAmt) { }
                column(AmountInWordAED; AmountInWordINR) { }
                column(TotalAmtRecdINRVar; TotalAmtRecdINRVar) { }

                column(AmountInWordUSD; AmountInWordUSD) { }
                column(AmountInWordEUR; AmountInWordEUR) { }
                column(AmountInWordRUB; AmountInWordRUB) { }

                #endregion

                trigger OnPreDataItem()
                begin
                    Clear(TotalAmtRecdINRVar);
                    RecRef.OPEN(DATABASE::"Purch. Inv. Line");
                    FildRef := RecRef.Field(3);
                    FildRef.SetRange(ReqFiltNo);
                end;

                #region [GST Details]
                trigger OnAfterGetRecord()
                begin
                    Clear(AmountInWordINR);
                    Clear(CGSTPer);
                    DGSTLedEntry.Reset();
                    DGSTLedEntry.SetRange("Document No.", Line."Document No.");
                    DGSTLedEntry.SetRange("No.", Line."No.");
                    DGSTLedEntry.SetRange("Document Line No.", Line."Line No.");
                    if DGSTLedEntry.FindFirst() then begin
                        repeat
                            // NetAmt += -DGSTLedEntry."GST Amount";
                            if DGSTLedEntry."GST Component Code" = 'CGST' then begin
                                CGSTAmt += -DGSTLedEntry."GST Amount";
                                CGSTPer := DGSTLedEntry."GST %";
                            end;
                            if DGSTLedEntry."GST Component Code" = 'SGST' then begin
                                SGSTAmt += -DGSTLedEntry."GST Amount";
                                SGSTPer := DGSTLedEntry."GST %";
                            end;
                            if DGSTLedEntry."GST Component Code" = 'IGST' then begin
                                IGSTAmt += -DGSTLedEntry."GST Amount";
                                IGSTPer := DGSTLedEntry."GST %";
                            end;
                        until DGSTLedEntry.Next() = 0;
                        TotalAmtRecdINRVar += Line.Amount + NetAmt;
                    end else begin
                        TotalAmtRecdINRVar += Line.Amount;
                    end;
                    TotalAmount := TotalAmtRecdINRVar + IGSTAmt + CGSTAmt + SGSTAmt;



                    AmountInWordINR := "AmtInWords-Rupees"(Round(TotalAmount, 0.01));
                    // DetailedGST_Rates.SetRange(); 


                    RecTAXTransValue.Reset();
                    RecTaxComponent.Reset();
                    // RecTAXTransValue.SetFilter("Tax Record ID", '%1', RecID);
                    RecTAXTransValue.SetFilter(Amount, '<>0');
                    RecTAXTransValue.SetFilter("Visible on Interface", 'Yes');
                    // SubTotal = 
                end;
                #endregion


            }
            #region [OnAfterGetRecord]
            trigger OnAfterGetRecord()
            begin
                Customer.Reset();
                Customer.SetRange("No.", "Sell-to Customer No.");
                if Customer.FindFirst() then begin
                    CustPanNo := Customer."P.A.N. No.";
                    CustStateCode := Customer."State Code";
                    CustNo := Customer."Mobile Phone No.";
                end;
                Location.Reset();
                Location.SetRange(Code, "Location Code");
                if Location.FindFirst() then begin
                    LocName := Location.Name;
                    LocAdd := Location.Address;
                    LocAdd2 := Location."Address 2";
                    LocPostCode := Location."Post Code";
                    LocCity := Location.City;
                    LocGst := Location."GST Registration No.";
                    FromState := Location."State Code";
                end;
                CompanyInfo.Reset();
                CompanyInfo.SetRange("State Code", StateName);
                if CompanyInfo.FindFirst() then begin
                    CompName := States.Description;
                    CompCode := States."State Code (GST Reg. No.)"
                end;
                States.Reset();
                States.SetRange(Code, "Location State Code");
                if States.FindFirst() then begin
                    StateName := States.Description;
                    StateCode := States."State Code (GST Reg. No.)"
                end;
                Address.Reset();
                Address.SetRange(Code, "Ship-to Code");
                if Address.FindFirst() then begin
                    StaName := Address.State;
                end;
                AddressState.Reset();
                AddressState.SetRange(Code, StaName);
                if AddressState.FindFirst() then begin
                    StaDes := AddressState.Description;
                    StaCode := AddressState."State Code (GST Reg. No.)";
                end;
            end;
            #endregion
        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
    end;
    #region [Var]
    var
        RecTAXTransValue: Record "Tax Transaction Value";
        RecTaxComponent: Record "Tax Component";
        DGSTLedEntry: Record "Detailed GST Ledger Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        Location: Record Location;
        Address: Record "Ship-to Address";
        States: Record State;
        AddressState: Record State;
        LocName: Text[100];
        LocAdd: Text[100];
        LocAdd2: Text[100];
        LocPostCode: Code[20];
        LocCity: Text[30];
        LocGst: Code[20];
        TotalAmount: Decimal;
        CGSTPer: Decimal;
        SGSTPer: Decimal;
        IGSTPer: Decimal;
        GSTPer: Decimal;
        RoundOff: Boolean;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        NetAmt: Decimal;
        CustPanNo: Code[30];
        CustStateCode: Code[10];
        CustNo: Text[30];
        FromState: Code[10];
        CompName: Text[50];
        CompCode: Code[10];
        StaName: Text[50];
        StaDes: Text[50];
        StaCode: Code[10];
        StateName: Text[50];
        StateCode: Code[10];
        TotalAmtRecdINRVar: Decimal;
        RecRef: RecordRef;
        FildRef: FieldRef;
        ReqFiltNo: Code[20];
        AmountInWordRUB: Text;
        AmountInWordEUR: Text;
        AmountInWords: Text[300];
        AmountInWordINR: Text;
        AmountInWordUSD: Text;
        WholePart: Integer;
        DecimalAsString: Text;
        TotalDigit: Integer;
        DigitAfterDecimal: Integer;
        DigitCount: Integer;
        DecimalPart: Integer;
        WholeInWords: Text[300];
        DecimalInWords: Text[300];
        OnesText: ARRAY[20] OF Text[30];
        TensText: ARRAY[10] OF Text[30];
        ThousText: array[5] of Text[30];
        ExponentText: ARRAY[5] OF Text[30];
        Text026: Label 'Zero';
        Text027: Label 'Hundred';
        Text028: Label 'And';
        Text029: Label '%1 results in a written number that is too long.';
    #endregion

    procedure NumberInWordsRUB(number: Decimal; CurrencyName: Text[30]; DenomName: Text[30]): Text[300]
    begin
        WholePart := ROUND(ABS(number), 1, '<');
        // For Calculating Digit after decimal
        DecimalAsString := Format(number);
        if StrPos(DecimalAsString, '.') > 0 then begin
            TotalDigit := STRLEN(STRSUBSTNO(DecimalAsString, STRPOS(DecimalAsString, '.') + 1));
            DigitAfterDecimal := StrPos(DecimalAsString, '.');
            DigitCount := TotalDigit - DigitAfterDecimal;
        end;
        // For Calculating Digit after decimal
        // Condition based on DigitCount//
        if DigitCount = 1 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 10);
        end
        else if DigitCount = 2 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 100);
        end
        else if DigitCount = 3 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 1000);
        end
        else
            DecimalPart := ABS((ABS(number) - WholePart) * 10000); //Changed for 4 digit(*10000)
        WholeInWords := NumberToWords(WholePart, CurrencyName);
        IF DecimalPart <> 0 THEN BEGIN
            DecimalInWords := NumberToWords(DecimalPart, 'Kopecks ');
            if (CurrencyName = 'RUB') or (CurrencyName = '') then
                WholeInWords := WholeInWords + 'Rubles And ' + DecimalInWords
            Else
                WholeInWords := WholeInWords + ' And ' + DecimalInWords;
        END
        Else if (CurrencyName = 'RUB') or (CurrencyName = '') then
            WholeInWords := WholeInWords + 'Kopecks '
        else
            WholeInWords := WholeInWords;
        AmountInWords := WholeInWords + 'Only';
        EXIT(AmountInWords);
    end;
    #region [Amountinwords]
    //BELOW CODE FOR AMOUNT TO WORDS CONVERSION//
    procedure NumberInWordsUSD(number: Decimal; CurrencyName: Text[30]; DenomName: Text[30]): Text[300]
    begin
        WholePart := ROUND(ABS(number), 1, '<');
        // For Calculating Digit after decimal
        DecimalAsString := Format(number);
        if StrPos(DecimalAsString, '.') > 0 then begin
            TotalDigit := STRLEN(STRSUBSTNO(DecimalAsString, STRPOS(DecimalAsString, '.') + 1));
            DigitAfterDecimal := StrPos(DecimalAsString, '.');
            DigitCount := TotalDigit - DigitAfterDecimal;
        end;
        // For Calculating Digit after decimal
        // Condition based on DigitCount//
        if DigitCount = 1 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 10);
        end
        else if DigitCount = 2 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 100);
        end
        else if DigitCount = 3 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 1000);
        end
        else
            DecimalPart := ABS((ABS(number) - WholePart) * 10000); //Changed for 4 digit(*10000)
        WholeInWords := NumberToWords(WholePart, CurrencyName);
        IF DecimalPart <> 0 THEN BEGIN
            DecimalInWords := NumberToWords(DecimalPart, 'Cents ');
            if (CurrencyName = 'USD') or (CurrencyName = '') then
                WholeInWords := WholeInWords + 'Dollars And ' + DecimalInWords
            Else
                WholeInWords := WholeInWords + ' And ' + DecimalInWords;
        END
        Else if (CurrencyName = 'USD') or (CurrencyName = '') then
            WholeInWords := WholeInWords + 'Dollars '
        else
            WholeInWords := WholeInWords;
        AmountInWords := WholeInWords + 'Only';
        EXIT(AmountInWords);
    end;
    //Amount in words conversion for EURO
    procedure NumberInWordsEUR(number: Decimal; CurrencyName: Text[30]; DenomName: Text[30]): Text[300]
    begin
        WholePart := ROUND(ABS(number), 1, '<');
        // For Calculating Digit after decimal
        DecimalAsString := Format(number);
        if StrPos(DecimalAsString, '.') > 0 then begin
            TotalDigit := STRLEN(STRSUBSTNO(DecimalAsString, STRPOS(DecimalAsString, '.') + 1));
            DigitAfterDecimal := StrPos(DecimalAsString, '.');
            DigitCount := TotalDigit - DigitAfterDecimal;
        end;
        // For Calculating Digit after decimal
        // Condition based on DigitCount//
        if DigitCount = 1 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 10);
        end
        else if DigitCount = 2 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 100);
        end
        else if DigitCount = 3 then begin
            DecimalPart := ABS((ABS(number) - WholePart) * 1000);
        end
        else
            DecimalPart := ABS((ABS(number) - WholePart) * 10000); //Changed for 4 digit(*10000)
        WholeInWords := NumberToWords(WholePart, CurrencyName);
        IF DecimalPart <> 0 THEN BEGIN
            DecimalInWords := NumberToWords(DecimalPart, 'Cents ');
            if (CurrencyName = 'EUR') or (CurrencyName = '') then
                WholeInWords := WholeInWords + 'Euros And ' + DecimalInWords
            Else
                WholeInWords := WholeInWords + ' And ' + DecimalInWords;
        END
        Else if (CurrencyName = 'EUR') or (CurrencyName = '') then
            WholeInWords := WholeInWords + 'Euros '
        else
            WholeInWords := WholeInWords;
        AmountInWords := WholeInWords + 'Only';
        EXIT(AmountInWords);
    end;
    //Amount in words conversion for EURO
    procedure NumberToWords(number: Decimal; appendScale: Text[30]): Text[300]
    var
        numString: Text[300];
        pow: Integer;
        powStr: Text[50];
        log: Integer;
    begin
        numString := '';
        IF number < 100 THEN
            IF number < 20 THEN BEGIN
                IF number <> 0 THEN numString := OnesText[number];
            END
            ELSE BEGIN
                numString := TensText[number DIV 10];
                IF (number MOD 10) > 0 THEN numString := numString + ' ' + OnesText[number MOD 10];
            END
        ELSE BEGIN
            pow := 0;
            powStr := '';
            IF number < 1000 THEN BEGIN // number is between 100 and 1000
                pow := 100;
                powStr := ThousText[1];
            END
            ELSE BEGIN // find the scale of the number
                log := ROUND(STRLEN(FORMAT(number DIV 1000)) / 3, 1, '>');
                pow := POWER(1000, log);
                powStr := ThousText[log + 1];
            END;
            numString := NumberToWords(number DIV pow, powStr) + ' ' + NumberToWords(number MOD pow, '');
        END;
        EXIT(DELCHR(numString, '<>', ' ') + ' ' + appendScale);
    end;

    procedure InitTextVariable1()
    begin
        OnesText[1] := 'One';
        OnesText[2] := 'Two';
        OnesText[3] := 'Three';
        OnesText[4] := 'Four';
        OnesText[5] := 'Five';
        OnesText[6] := 'Six';
        OnesText[7] := 'Seven';
        OnesText[8] := 'Eight';
        OnesText[9] := 'Nine';
        OnesText[10] := 'Ten';
        OnesText[11] := 'Eleven';
        OnesText[12] := 'Twelve';
        OnesText[13] := 'Thirteen';
        OnesText[14] := 'Fourteen';
        OnesText[15] := 'Fifteen';
        OnesText[16] := 'Sixteen';
        OnesText[17] := 'Seventeen';
        OnesText[18] := 'Eighteen';
        OnesText[19] := 'Ninteen';
        TensText[1] := '';
        TensText[2] := 'Twenty';
        TensText[3] := 'Thirty';
        TensText[4] := 'Forty';
        TensText[5] := 'Fifty';
        TensText[6] := 'Sixty';
        TensText[7] := 'Seventy';
        TensText[8] := 'Eighty';
        TensText[9] := 'Ninety';
        ThousText[1] := 'Hundred';
        ThousText[2] := 'Thousand';
        ThousText[3] := 'Million';
        ThousText[4] := 'Billion';
        ThousText[5] := 'Trillion';
    end;

    ///amt in USD to words//  
    PROCEDURE "AmtInWords-Rupees"(Mamount: Decimal): Text[300];
    VAR
        paise: Integer;
        crore: Integer;
        lakh: Integer;
        thousand: Integer;
        hundred: Integer;
        rupee: Integer;
        intamount: Decimal;
        AMTTEXT: Text[300];
    BEGIN
        intamount := ROUND(Mamount, 1, '<');
        paise := (Mamount - intamount) * 100;
        crore := ROUND(Mamount / 10000000, 1, '<');
        Mamount := Mamount MOD 10000000;
        lakh := ROUND(Mamount / 100000, 1, '<');
        Mamount := Mamount MOD 100000;
        thousand := ROUND(Mamount / 1000, 1, '<');
        Mamount := Mamount MOD 1000;
        hundred := ROUND(Mamount / 100, 1, '<');
        rupee := ROUND((Mamount MOD 100), 1, '<');
        AMTTEXT += '';
        IF crore <> 0 THEN AMTTEXT += Rno(crore) + ' Crore ';
        IF lakh <> 0 THEN AMTTEXT += Rno(lakh) + ' Lakh ';
        IF thousand <> 0 THEN AMTTEXT += Rno(thousand) + ' Thousand ';
        IF hundred <> 0 THEN AMTTEXT += Rno(hundred) + ' Hundred ';
        IF rupee <> 0 THEN AMTTEXT += Rno(rupee) + ' ';
        IF paise <> 0 THEN
            AMTTEXT += 'And ' + Rno(paise) + ' ' + 'Paisa Only'
        ELSE
            AMTTEXT += 'And' + ' ' + 'Zero' + ' ' + 'Paisa Only';
        //AMTTEXT += '';
        //AMTTEXT += 'And ' + Rno(paise) + ' ' + 'Paisa Only';
        EXIT(AMTTEXT);
    END;

    PROCEDURE Rno(No: Integer): Text[30];
    BEGIN
        IF No = 0 THEN EXIT('Zero');
        IF No = 1 THEN EXIT('One');
        IF No = 2 THEN EXIT('Two');
        IF No = 3 THEN EXIT('Three');
        IF No = 4 THEN EXIT('Four');
        IF No = 5 THEN EXIT('Five');
        IF No = 6 THEN EXIT('Six');
        IF No = 7 THEN EXIT('Seven');
        IF No = 8 THEN EXIT('Eight');
        IF No = 9 THEN EXIT('Nine');
        IF No = 10 THEN EXIT('Ten');
        IF No = 11 THEN EXIT('Eleven');
        IF No = 12 THEN EXIT('Twelve');
        IF No = 13 THEN EXIT('Thirteen');
        IF No = 14 THEN EXIT('Fourteen');
        IF No = 15 THEN EXIT('Fifteen');
        IF No = 16 THEN EXIT('Sixteen');
        IF No = 17 THEN EXIT('Seventeen');
        IF No = 18 THEN EXIT('Eighteen');
        IF No = 19 THEN EXIT('Nineteen');
        IF No = 20 THEN EXIT('Twenty');
        IF No = 21 THEN EXIT('Twenty One');
        IF No = 22 THEN EXIT('Twenty Two');
        IF No = 23 THEN EXIT('Twenty Three');
        IF No = 24 THEN EXIT('Twenty Four');
        IF No = 25 THEN EXIT('Twenty Five');
        IF No = 26 THEN EXIT('Twenty Six');
        IF No = 27 THEN EXIT('Twenty Seven');
        IF No = 28 THEN EXIT('Twenty Eight');
        IF No = 29 THEN EXIT('Twenty Nine');
        IF No = 30 THEN EXIT('Thirty');
        IF No = 31 THEN EXIT('Thirty One');
        IF No = 32 THEN EXIT('Thirty Two');
        IF No = 33 THEN EXIT('Thirty Three');
        IF No = 34 THEN EXIT('Thirty Four');
        IF No = 35 THEN EXIT('Thirty Five');
        IF No = 36 THEN EXIT('Thirty Six');
        IF No = 37 THEN EXIT('Thirty Seven');
        IF No = 38 THEN EXIT('Thirty Eight');
        IF No = 39 THEN EXIT('Thirty Nine');
        IF No = 40 THEN EXIT('Forty');
        IF No = 41 THEN EXIT('Forty One');
        IF No = 42 THEN EXIT('Forty Two');
        IF No = 43 THEN EXIT('Forty Three');
        IF No = 44 THEN EXIT('Forty Four');
        IF No = 45 THEN EXIT('Forty Five');
        IF No = 46 THEN EXIT('Forty Six');
        IF No = 47 THEN EXIT('Forty Seven');
        IF No = 48 THEN EXIT('Forty Eight');
        IF No = 49 THEN EXIT('Forty Nine');
        IF No = 50 THEN EXIT('Fifty');
        IF No = 51 THEN EXIT('Fifty One');
        IF No = 52 THEN EXIT('Fifty Two');
        IF No = 53 THEN EXIT('Fifty Three');
        IF No = 54 THEN EXIT('Fifty Four');
        IF No = 55 THEN EXIT('Fifty Five');
        IF No = 56 THEN EXIT('Fifty Six');
        IF No = 57 THEN EXIT('Fifty Seven');
        IF No = 58 THEN EXIT('Fifty Eight');
        IF No = 59 THEN EXIT('Fifty Nine');
        IF No = 60 THEN EXIT('Sixty');
        IF No = 61 THEN EXIT('Sixty One');
        IF No = 62 THEN EXIT('Sixty Two');
        IF No = 63 THEN EXIT('Sixty Three');
        IF No = 64 THEN EXIT('Sixty Four');
        IF No = 65 THEN EXIT('Sixty Five');
        IF No = 66 THEN EXIT('Sixty Six');
        IF No = 67 THEN EXIT('Sixty Seven');
        IF No = 68 THEN EXIT('Sixty Eight');
        IF No = 69 THEN EXIT('Sixty Nine');
        IF No = 70 THEN EXIT('Seventy');
        IF No = 71 THEN EXIT('Seventy One');
        IF No = 72 THEN EXIT('Seventy Two');
        IF No = 73 THEN EXIT('Seventy Three');
        IF No = 74 THEN EXIT('Seventy Four');
        IF No = 75 THEN EXIT('Seventy Five');
        IF No = 76 THEN EXIT('Seventy Six');
        IF No = 77 THEN EXIT('Seventy Seven');
        IF No = 78 THEN EXIT('Seventy Eight');
        IF No = 79 THEN EXIT('Seventy Nine');
        IF No = 80 THEN EXIT('Eighty');
        IF No = 81 THEN EXIT('Eighty One');
        IF No = 82 THEN EXIT('Eighty Two');
        IF No = 83 THEN EXIT('Eighty Three');
        IF No = 84 THEN EXIT('Eighty Four');
        IF No = 85 THEN EXIT('Eighty Five');
        IF No = 86 THEN EXIT('Eighty Six');
        IF No = 87 THEN EXIT('Eighty Seven');
        IF No = 88 THEN EXIT('Eighty Eight');
        IF No = 89 THEN EXIT('Eighty Nine');
        IF No = 90 THEN EXIT('Ninety');
        IF No = 91 THEN EXIT('Ninety One');
        IF No = 92 THEN EXIT('Ninety Two');
        IF No = 93 THEN EXIT('Ninety Three');
        IF No = 94 THEN EXIT('Ninety Four');
        IF No = 95 THEN EXIT('Ninety Five');
        IF No = 96 THEN EXIT('Ninety Six');
        IF No = 97 THEN EXIT('Ninety Seven');
        IF No = 98 THEN EXIT('Ninety Eight');
        IF No = 99 THEN EXIT('Ninety Nine');
    END;

    PROCEDURE FormatNoText(VAR NoText: ARRAY[2] OF Text[80]; No: Decimal; CurrencyCode: Code[10]);
    VAR
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
        Currency: Record 4;
        TensDec: Integer;
        OnesDec: Integer;
    BEGIN
        CLEAR(NoText);
        NoTextIndex := 1;
        NoText[1] := '';
        IF No < 1 THEN
            AddToNoText(NoText, NoTextIndex, PrintExponent, Text026)
        ELSE BEGIN
            FOR Exponent := 4 DOWNTO 1 DO BEGIN
                PrintExponent := FALSE;
                IF No > 99999 THEN BEGIN
                    Ones := No DIV (POWER(100, Exponent - 1) * 10);
                    Hundreds := 0;
                END
                ELSE BEGIN
                    Ones := No DIV POWER(1000, Exponent - 1);
                    Hundreds := Ones DIV 100;
                END;
                Tens := (Ones MOD 100) DIV 10;
                Ones := Ones MOD 10;
                IF Hundreds > 0 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, Text027);
                END;
                IF Tens >= 2 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    IF Ones > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                END
                ELSE IF (Tens * 10 + Ones) > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                IF PrintExponent AND (Exponent > 1) THEN AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                IF No > 99999 THEN
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(100, Exponent - 1) * 10
                ELSE
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(1000, Exponent - 1);
            END;
        END;
        IF CurrencyCode <> '' THEN BEGIN
            Currency.GET(CurrencyCode);
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ' + Currency.Description);
        END
        ELSE
            AddToNoText(NoText, NoTextIndex, PrintExponent, 'RUPEES');
        AddToNoText(NoText, NoTextIndex, PrintExponent, Text028);
        TensDec := ((No * 100) MOD 100) DIV 10;
        OnesDec := (No * 100) MOD 10;
        IF TensDec >= 2 THEN BEGIN
            AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[TensDec]);
            IF OnesDec > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[OnesDec]);
        END
        ELSE IF (TensDec * 10 + OnesDec) > 0 THEN
            AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[TensDec * 10 + OnesDec])
        ELSE
            AddToNoText(NoText, NoTextIndex, PrintExponent, Text026);
        IF (CurrencyCode <> '') THEN
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ' + Currency.Description + ' ONLY')
        ELSE
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' PAISA ONLY');
    END;

    LOCAL PROCEDURE AddToNoText(VAR NoText: ARRAY[2] OF Text[80]; VAR NoTextIndex: Integer; VAR PrintExponent: Boolean; AddText: Text[30]);
    BEGIN
        PrintExponent := TRUE;
        WHILE STRLEN(NoText[NoTextIndex] + ' ' + AddText) > MAXSTRLEN(NoText[1]) DO BEGIN
            NoTextIndex := NoTextIndex + 1;
            IF NoTextIndex > ARRAYLEN(NoText) THEN ERROR(Text029, AddText);
        END;
        NoText[NoTextIndex] := DELCHR(NoText[NoTextIndex] + ' ' + AddText, '<');
    END;
    //ABOVE CODE FOR AMOUNT TO WORDS CONVERSION//
    #endregion

}