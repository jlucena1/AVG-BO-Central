tableextension 50103 "AVG Location Ext." extends Location
{
    fields
    {
        field(50100; "AVG Distribution Center"; Boolean)
        {
            Caption = 'Distribution Center';
            DataClassification = CustomerContent;
        }
    }
}
