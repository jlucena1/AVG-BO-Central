tableextension 50101 "AVG Item Ext." extends Item
{
    fields
    {
        field(50100; "AVG Non Returnable"; Boolean)
        {
            Caption = 'Non Returnable';
            DataClassification = CustomerContent;
        }
    }
}
