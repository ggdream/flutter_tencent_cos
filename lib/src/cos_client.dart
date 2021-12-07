import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'cos_clientbase.dart';
import 'cos_comm.dart';
import "cos_config.dart";
import 'cos_exception.dart';
import "cos_model.dart";

class COSClient extends COSClientBase {
  COSClient(COSConfig _config) : super(_config);

  Future<ListBucketResult> listObject({String prefix = ""}) async {
    cosLog("listObject");
    var response = await getResponse("GET", "/", params: {"prefix": prefix});
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    String xmlContent = await response.transform(utf8.decoder).join("");
    if (response.statusCode != 200) {
      throw COSException(response.statusCode, xmlContent);
    }
    var content = XmlDocument.parse(xmlContent);
    return ListBucketResult(content.rootElement);
  }

  putObject(String objectKey, String filePath) async {
    cosLog("putObject");
    var f = File(filePath);
    int flength = await f.length();
    var fs = f.openRead();
    var req = await getRequest("PUT", objectKey, headers: {
      "content-type": "image/jpeg",
      "content-length": flength.toString()
    });
    await req.addStream(fs);
    var response = await req.close();
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    if (response.statusCode != 200) {
      cosLog("putObject error");
      String content = await response.transform(utf8.decoder).join("");
      throw COSException(response.statusCode, content);
    }
  }

 Future<dynamic> putObjectX(String objectKey, String filePath, { required int startTime, required int expiredTime, required String token,}) async {
    cosLog("putObject");
    var f = File(filePath);
    int flength = await f.length();
    var fs = f.openRead();
    var req = await getRequestX("PUT", objectKey, headers: {
      "content-type": "image/jpeg",
      "content-length": flength.toString()
    }, startTime: startTime, expiredTime: expiredTime, token: token);
    await req.addStream(fs);
    return await req.close();
    // cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    // if (response.statusCode != 200) {
    //   cosLog("putObject error");
    //   String content = await response.transform(utf8.decoder).join("");
    //   throw COSException(response.statusCode, content);
    // }
  }

  deleteObject(String objectKey) async {
    cosLog("deleteObject");
    var response = await getResponse("DELETE", objectKey);
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    if (response.statusCode != 204) {
      cosLog("deleteObject error");
      String content = await response.transform(utf8.decoder).join("");
      throw COSException(response.statusCode, content);
    }
  }
}
