declare module "@salesforce/apex/ImageUploaderHandler.saveFile" {
  export default function saveFile(param: {recordId: any, strFileName: any, base64Data: any}): Promise<any>;
}
declare module "@salesforce/apex/ImageUploaderHandler.setImageUrl" {
  export default function setImageUrl(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImageUploaderHandler.deleteFiles" {
  export default function deleteFiles(param: {recordId: any}): Promise<any>;
}
