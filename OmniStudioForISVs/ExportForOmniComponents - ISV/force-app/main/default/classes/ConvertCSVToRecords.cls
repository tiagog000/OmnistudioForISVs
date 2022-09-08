/************************************************************

*** @description Invocable Action to convert CSV Records in a ContentDocument to SObject records. The CSV column names should match the SObject field api names. The records are returned to the Flow, they are not actually inserted.
*** 
**/
global without sharing class ConvertCSVToRecords {

    @InvocableMethod(label='Convert CSV File to Records from single StaticResource')
    global static Response[] convert(Request[] inputs) {
        Response[] responseList = new List<Response>{};

    for (Request curInput : inputs) {
        Response output = new Response();
        output.convertedCSVRows = new List<SObject>{};
        if (curInput.StaticResourceName == null) {
            throw new FlowCustomException(
            'You need to provide one Static Resource Id to be queried '
        );
    }
    System.debug('running'); 
    List<SObject> curFileConvertedCSVRows = new List<SObject>();
    Blob csvBlobContent = getCsvContent(curInput.StaticResourceName);
    String CSV = blobToString(csvBlobContent, 'UTF-8');
    String cell = '';
    List<String> row = new List<String>();
    List<List<String>> listedCSV = new List<List<String>>();
    Integer headerIndex = 0;
    Integer rowIndex = 0;
    Boolean InsideDoubleQuotes = false;
    Integer countOfDoubleQuotesInsideDoubleQuote = 0;
    Integer countOfNewLineInsideDoubleQuote = 0;
    Integer countOfCommaInsideDoubleQuote = 0;
    // Need logic to split string into lines
    for(Integer index = 0; index < csv.length(); index++) {
        String character = CSV.substring(index, index+1);
            if (character == '"') {
                if(InsideDoubleQuotes == false) {
                    InsideDoubleQuotes = true;
                    countOfDoubleQuotesInsideDoubleQuote += 1;
                    cell += character;
                }else{
                    countOfDoubleQuotesInsideDoubleQuote += 1;
                    cell += character;
                    }
                } 
                else if(character == ',') {
                        if(countOfDoubleQuotesInsideDoubleQuote > 0 && math.mod(countOfDoubleQuotesInsideDoubleQuote,2) == 0) {
                             InsideDoubleQuotes = false;
                        }
                        if(InsideDoubleQuotes == false) {
                            String unescapedCSV = cell.unescapeCsv();
                            row.add(unescapedCSV);
                            cell = '';
                            headerIndex += 1;
                            countOfCommaInsideDoubleQuote = 0;
                        } else {
                            cell += character;
                             countOfCommaInsideDoubleQuote += 1;
                        }
                    }
                    else if (character == '\n') {
                        if(countOfDoubleQuotesInsideDoubleQuote > 0 && math.mod(countOfDoubleQuotesInsideDoubleQuote,2) == 0) {
                            InsideDoubleQuotes = false;
                        }
                        if(InsideDoubleQuotes == false) {
                            String unescapedCSV = cell.unescapeCsv();
                            row.add(unescapedCSV);
                            cell = '';
                            listedCSV.add(new List<String>(row));
                            row.clear();
                            rowIndex += 1;
                            countOfNewLineInsideDoubleQuote = 0;
                    } else {
                            cell += character;
                            countOfNewLineInsideDoubleQuote += 1;
                        }
                    } 
                else {
                    cell += character;
                }
            }
            // Build JSON String
            String JSONString = '[';
            try{
            for(Integer i = 1; i < listedCSV.size(); i++){
                List<String> rowValues = listedCSV[i];
                JSONString = JSONString + '{';
                for(Integer j = 0; j < rowValues.size(); j++) {
                    // This is the money, double calling escapeJava
                    JSONString = JSONString +'"' + listedCSV[0][j].escapeJava().escapeJava() + '"' + ':' + '"' + listedCSV[i][j].escapeJava().escapeJava() + '"' + ',';     
                }
                JSONString = JSONString.removeEnd(',');
                JSONString = JSONString  + '},';    
            }} catch (Exception e) {System.debug('Error');}
            JSONString = JSONString.removeEnd(',');
            JSONString = JSONString + ']';
        System.debug(JSONString);
        output.convertedCSVRows.addAll((List<SObject>)JSON.deserializeStrict(JSONString.unescapeJava(), Type.forName('List<'+ curInput.objectApiName+'>')));
        responseList.add(output);
    }
    return responseList;
  }
    
  @TestVisible
  private static Blob getCsvContent(String StaticResource) {
    if(!Test.isRunningTest()){
       StaticResource csvFile = [
          SELECT Body
          FROM StaticResource
          WHERE Name = :StaticResource AND NamespacePrefix ='OmniPackaging' Limit 1
        ];
        return csvFile.Body;
      } else{
          ContentVersion csvFile = [
              SELECT VersionData
              FROM ContentVersion
              WHERE ContentDocumentId = :StaticResource AND IsLatest = TRUE
            ];
        return csvFile.VersionData;
      }
  }

  /* Converting the CSV file input(BLOB format) to a string */
@TestVisible  
private static String blobToString(Blob input, String inCharset) {
    String hex = EncodingUtil.convertToHex(input);
    System.assertEquals(0, hex.length() & 1);
    final Integer bytesCount = hex.length() >> 1;
    String[] bytes = new List<String>(bytesCount);
    for (Integer i = 0; i < bytesCount; ++i)
      bytes[i] = hex.mid(i << 1, 2);
    return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
  }
  global class FlowCustomException extends Exception {
      }
  global class Request {
    global Request() {
    }

    @InvocableVariable(label='Object API Name' required=true)
    global String objectApiName;

    @InvocableVariable(label='Static (single) Resource Name' required=true)
    global String StaticResourceName;

  }

  global class Response {
    @InvocableVariable(label='List(collection) of Records')
    global List<SObject> convertedCSVRows;
  }
}