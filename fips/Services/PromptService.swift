import Foundation

struct PromptService {
    static func getReceiptPrompt(rawText: String) -> String {
        """
        Format the following receipt text into a structured format. Extract:
        - Store name
        - Date
        - Items with prices
        - Subtotal
        - Tax
        - Total

        Raw receipt text:
        \(rawText)
        
        Format as:
        Store: [store name]
        Date: [date]
        
        Items:
        - [item] - $[price]
        
        Subtotal: $[amount]
        Tax: $[amount]
        Total: $[amount]
        """
    }
    
    static func getSystemPrompt() -> String {
        """
        You have raw OCR text for a receipt. Convert it into a concise, structured format, per the guidelines in the XML below. Reference the example carefully. Do not invent data; mark unclear text as “OCR uncertain.” Output only the final structured receipt.

        <SystemPrompt>
          <Instructions>
            <Goal>
              Transform raw OCR text into an organized receipt.
            </Goal>
            <Format>
              ReceiptDetails, ItemsPurchased, Totals, PaymentDetails, LoyaltyProgram, AdditionalText, NotesOnOCRAmbiguities
            </Format>
          </Instructions>

          <Example>
            <RawText>
              GR8 GROCERIES
              LOC: 129 Westwood
              Date/Time: 24/01/25 14:57
              BANANAS ORG
              $2.49
              SUB-TOTAL 7.99
              TAX 1.04
              TOTAL 9.03
              PURCHASE DEBIT
              Auth: 345678
            </RawText>
            <StructuredOutput>
              <ReceiptDetails>
                <Store>GR8 GROCERIES</Store>
                <Location>129 Westwood</Location>
                <DateTime>24/01/25 14:57</DateTime>
              </ReceiptDetails>
              <ItemsPurchased>
                <Item>
                  <Name>BANANAS ORG</Name>
                  <Price>2.49</Price>
                </Item>
              </ItemsPurchased>
              <Totals>
                <Subtotal>7.99</Subtotal>
                <Tax>1.04</Tax>
                <Total>9.03</Total>
              </Totals>
              <PaymentDetails>
                <TransactionType>PURCHASE</TransactionType>
                <PaymentMethod>DEBIT</PaymentMethod>
                <Amount>9.03</Amount>
                <ApprovalCode>345678</ApprovalCode>
              </PaymentDetails>
              <NotesOnOCRAmbiguities>
                <Line>None</Line>
              </NotesOnOCRAmbiguities>
            </StructuredOutput>
          </Example>
        </SystemPrompt>
        """
    }
}
