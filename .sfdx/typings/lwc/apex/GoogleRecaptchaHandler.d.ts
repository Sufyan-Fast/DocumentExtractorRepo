declare module "@salesforce/apex/GoogleRecaptchaHandler.fetchBaseURL" {
  export default function fetchBaseURL(): Promise<any>;
}
declare module "@salesforce/apex/GoogleRecaptchaHandler.isVerified" {
  export default function isVerified(param: {recaptchaResponse: any, recaptchaSecretKey: any}): Promise<any>;
}
