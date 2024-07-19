public with sharing class EmailController {

    @InvocableMethod(label='Send Email with Attachments')
    public static void sendEmailWithAttachments(
      List<InputVarForEMail> emailWrap
    ) {
      string senderEmail = emailWrap[0].senderEmail;
      string fileNameEmail = emailWrap[0].fileNameEmail;
      string base64Data = emailWrap[0].attachmentEmail;
      string subjectEmail = emailWrap[0].subjectEmail;
      string bodyEmail = emailWrap[0].bodyEmail;
      list<string> receipentEmail = emailWrap[0].receipentEmail;
      // Filter out null values from receipentEmail list
      List<String> filteredReceipentEmail = new List<String>();
      for (String email : receipentEmail) {
        if (email != null) {
          filteredReceipentEmail.add(email);
        }
      }
      List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

      Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
      // Assuming attachment names are provided in a separate list and are accessible in the class
      attachment.setFileName(fileNameEmail); // You might want to customize the file name here
      attachment.setBody(EncodingUtil.base64Decode(base64Data));
      attachments.add(attachment);

      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(filteredReceipentEmail);
      email.setSubject(subjectEmail);
      email.setHTMLBody(bodyEmail);
      email.setFileAttachments(attachments);

      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }

    public class InputVarForEMail {
      @InvocableVariable(label='Sender Email Adress' required=true)
      public String senderEmail;
      @InvocableVariable(label='Receiver Email Adress')
      public list<String> receipentEmail;
      @InvocableVariable(label='Email Subject')
      public String subjectEmail;
      @InvocableVariable(label='Attachment of email')
      public String attachmentEmail;
      @InvocableVariable(label='fileName of email')
      public String fileNameEmail;
      @InvocableVariable(label='body of email')
      public String bodyEmail;
    }
  }