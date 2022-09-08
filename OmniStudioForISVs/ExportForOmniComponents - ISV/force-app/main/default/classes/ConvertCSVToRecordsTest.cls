@IsTest
public with sharing class ConvertCSVToRecordsTest {
      private static final String SPACE = ' ';
      private static final String SAMPLE_DESCRIPTION = 'Sample Description';
      private static final String SAMPLE_DESCRIPTION_WITH_SPECIAL_CHARS = 'Sample Description with special chars âáéíóúüñ';
      private static final String DESCRIPTION_WITH_COMMAS_NEWLINE_AND_QUOTES = 'Agent, Commercial; Agent, Residential; Appraiser; Broker \n Business; ""Escrow Officer""; Landlord; Property Manager';
      private static final String DESCRIPTION_WITH_COMMAS_NEWLINE_AND_QUOTES_POST_PARSE = 'Agent, Commercial; Agent, Residential; Appraiser; Broker \n Business; "Escrow Officer"; Landlord; Property Manager'; // '""' is replaced indicates a single '"' within a column. The value after parsing should indicate that.
      private static final String NEW_YORK = 'New York';
      private static final String HOT = 'Hot';
      private static final String PERCENT_VAL_ONE = '23.2';
      private static final String PERCENT_VAL_TWO = '4.33';
	
	 @TestSetup
  	private static void createData() {
    ContentVersion cv = new ContentVersion(Title = 'Demo Accounts CSV', VersionData = createCSVBlob(), PathOnClient = 'DemoAccounts.csv');
    insert cv;
  }

	@IsTest
  private static void testconvertMethodExceptions() {
    ConvertCSVToRecords.Request[] flowInputs = createFlowInputsList();

    /* 1. FlowInput list size more than 1 exception
     */
    try {
      ConvertCSVToRecords.Request input = new ConvertCSVToRecords.Request();
      flowInputs.add(input);
      ConvertCSVToRecords.Response[] flowOutputs = ConvertCSVToRecords.convert(flowInputs);
    } catch (Exception e) {
      System.assert(
        e.getMessage().contains('You need to provide one')
      );
    }
  }
  
    private static ConvertCSVToRecords.Request[] createFlowInputsList() {
        String StaticResourceName;
        List<ContentDocument> cDocList = [SELECT Id FROM Contentdocument WHERE Title = 'Demo Accounts CSV'];
        ConvertCSVToRecords.Request[] flowInputs = new List<ConvertCSVToRecords.Request>{};
        ConvertCSVToRecords.Request input = new ConvertCSVToRecords.Request();
        input.objectApiName = 'Account';
        if (cDocList.size() == 1) {
          input.StaticResourceName = cDocList[0].Id;
        }
        flowInputs.add(input);
    
        return flowInputs;
      }
    private static Blob createCSVBlobWithSpecialChars() {
        String csvStringContent;
        Blob csvBlobContent;
        string[] fields = new List<String>{ 'Description', 'AnnualRevenue', 'NumberOfEmployees', 'Rating', 'Name', 'Site' };
    
        String csvHeader = String.join(fields, ',') + '\n';
        csvStringContent = csvHeader;
        csvStringContent += SPACE + SAMPLE_DESCRIPTION_WITH_SPECIAL_CHARS + ',500000,300,' + SPACE + HOT + ',"Acme, Inc",' + NEW_YORK + SPACE;
        csvStringContent += '\n';
        csvStringContent += '"' + DESCRIPTION_WITH_COMMAS_NEWLINE_AND_QUOTES + '",40000,30,Hot,"Universal Containers","Washington, DC"';
        csvStringContent += '\n';
        csvStringContent += ',40000,20,Hot,"Universal Containers", ';
        return Blob.valueOf(csvStringContent);
      }
	
	private static Blob createCSVBlob() {
        String csvStringContent;
        Blob csvBlobContent;
        string[] fields = new List<String>{ 'Description', 'AnnualRevenue', 'NumberOfEmployees', 'Rating', 'Name', 'Site' };
    
        String csvHeader = String.join(fields, ',') + '\n';
        csvStringContent = csvHeader;
        csvStringContent += SPACE + SAMPLE_DESCRIPTION + ',500000,300,' + SPACE + HOT + ',"Acme, Inc",' + NEW_YORK + SPACE;
        csvStringContent += '\n';
        csvStringContent += '"' + DESCRIPTION_WITH_COMMAS_NEWLINE_AND_QUOTES + '",40000,30,Hot,"Universal Containers","Washington, DC"';
        csvStringContent += '\n';
        csvStringContent += ',40000,20,Hot,"Universal Containers", ';
        return Blob.valueOf(csvStringContent);
  	}
}