# Introduction

This file records the sanitation done on top of the OAS from APIs guru. Google uses Google discovery format to expose API details. APIs guru uses a conversion tool to change the discovery documentation to OAS. These sanitation's are done for improving usability and as workaround for known limitations in language side.

1. Fix request body content types. Here, Gmail API accepts all content type. AS per [Discovery Doc](https://developers.google.com/discovery/v1/reference/apis) only media upload content type is specified. This is mistakenly mapped to request body content type in APIs guru transformation.

2. Remove resource paths,
    * /users/{userId}/settings - This path has around 20 odd sub paths and does not add significant usability.
    * /users/{userId}/watch & /users/{userId}/stop - This will be covered in Google PubSub

3. Streamline base path. Here the path `/gmail/v1` is moved to server url. This reduces complexity.

4. Move parameters `xgafv` and `alt` definitions to schemas. This ensures ballerina enums are created for the parameters not inline string unions.

5. Rename `Thread` schema to `MailThread`. This is done as a workaround for issue, [Openapi tool does not escape in built symbols](https://github.com/ballerina-platform/ballerina-standard-library/issues/5067)

6. Add description for `LabelColor` schema.

## OpenAPI cli command

```bash
bal openapi -i docs/open-api-spec/openapi.yaml --mode client -o ballerina/modules/oas
```
