pageextension 80112 PostedSalInv extends "Posted Sales Invoice"
{

    actions
    {
        addafter(Print)
        {
            action(TaxInvoice)
            {
                ApplicationArea = All;
                Caption = 'Tax Invoice GST New';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    IsHandled: Boolean;
                begin
                    RecSalesHdr.reset;
                    RecSalesHdr.SETRANGE("No.", Rec."No.");
                    IF RecSalesHdr.FINDFIRST THEN
                        REPORT.RUNMODAL(80119, TRUE, TRUE, RecSalesHdr);
                end;
            }
        }
    }

    var
        myInt: Integer;
        RecSalesHdr: Record "Sales Invoice Header";
}