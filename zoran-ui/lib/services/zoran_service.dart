import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:zoran.io/services/resource_service.dart';
import 'package:zoran.io/services/user_service.dart';

part 'zoran_service.g.dart';

class ZoranService extends Object {
  final Logger logger = new Logger('ZoranService');
  final String _baseUrl;

  ZoranService(@zoranIoUrl this._baseUrl);

  final _newPanel = new ResourceResponse(
      "",
      "Add new Resource",
      "",
      "",
      "",
      ResourceType.NEW,
      null,
      null,
      "Click to create new resource!",
      "",
      "",
      "",
      "",
      null,
      [],
      []);

  Future<VersionDto> getVersion() async {
    try {
      final url = '$_baseUrl/build-info';
      final response = await HttpRequest.getString(url);
      return new VersionDto.fromJson(json.decode(response));
    } catch (e, s) {
      logger.severe(e, s);
      rethrow;
    }
  }

  Future<List<ResourceResponse>> getResources() async {
    try {
      final url = '$_baseUrl/api/ui/resource/all';
      final response = await HttpRequest.getString(url);
      final detaillist = json.decode(response) as List;
      return detaillist
          .map((f) => ResourceResponse.fromJson(f))
          .toList()
          .cast<ResourceResponse>();
    } catch (e, s) {
      rethrow;
    }
  }

  Future<List<ResourceResponse>> getTemplates() async {
    try {
      final url = '$_baseUrl/api/ui/template';
      final response = await HttpRequest.getString(url);
      final detaillist = json.decode(response) as List;
      return detaillist
          .map((f) => ResourceResponse.fromJson(f))
          .toList()
          .cast<ResourceResponse>();
    } catch (e, s) {
      rethrow;
    }
  }

  Future<NewResourceModel> getNewResourceModel(String id,
      String version) async {
    try {
      String url = '$_baseUrl/api/ui/model/dependencies';
      if (id != null) {
        url = url + "?id=" + id;
        if (version != null) {
          url = url + "&version=" + version;
        }
      } else if (version != null) {
        url = url + "?version=" + version;
      }
      final response = await HttpRequest.getString(url);
      final json = jsonDecode(response) as Map;
      final result = json['dependencies']
          .map((f) => LanguageDependenciesModel.fromJson(f))
          .toList()
          .cast<LanguageDependenciesModel>();
      return NewResourceModel(version, result);
    } catch (e, s) {
      logger.severe(e, s);
      rethrow;
    }
  }

  Future<ResourceResponse> getResourceByItsId(String uniqueId) async {
    try {
      final url = '$_baseUrl/api/ui/resource/$uniqueId';
      final response = await HttpRequest.getString(url);
      return new ResourceResponse.fromJson(jsonDecode(response));
    } catch (e, s) {
      logger.severe(e, s);
      rethrow;
    }
  }

  Future<List<SingleCapability>> getCapability(String id) async {
    try {
      final url = '$_baseUrl/api/ui/model/capabilities?id=$id';
      final response = await HttpRequest.getString(url);
      final detaillist = json.decode(response);
      return detaillist
          .toList()
          .map((x) => SingleCapability.fromJson(x))
          .toList()
          .cast<SingleCapability>();
    } catch (e, s) {
      logger.severe(e, s);
      rethrow;
    }
  }

  Future<List<String>> getLicences() async {
    try {
      final url = '$_baseUrl/api/ui/model/licence';
      final response = await HttpRequest.getString(url);
      final licences = json.decode(response) as Map;
      return licences['licenseList']
          .map((f) => License.fromJson(f))
          .toList()
          .cast<String>();
    } catch (e, s) {
      logger.severe(e, s);
      rethrow;
    }
  }
}

@JsonSerializable()
class SingleCapability {
  String capabilityName;
  String name;
  String id;

  SingleCapability(this.capabilityName, this.name, this.id);

  factory SingleCapability.fromJson(Map<String, dynamic> json) =>
      _$SingleCapabilityFromJson(json);
}

@JsonSerializable(createToJson: false)
class VersionDto {
  String branch;
  String commitIdAbbrev;
  String buildHost;
  String buildTime;
  String buildVersion;

  VersionDto(this.branch, this.commitIdAbbrev,
      this.buildHost, this.buildTime, this.buildVersion);

  factory VersionDto.fromJson(Map<String, dynamic> json) =>
      _$VersionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class NewResourceModel {
  String version;
  List<LanguageDependenciesModel> dependencies; //language - list of dependencies

  factory NewResourceModel.fromJson(Map<String, dynamic> json) =>
      _$NewResourceModelFromJson(json);

  NewResourceModel(this.version, this.dependencies);
}

@JsonSerializable(createToJson: true)
class LanguageDependenciesModel {
  String parentIdentifier;
  String id;
  String name;
  String version;
  String description;
  ResourceType type;

  factory LanguageDependenciesModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageDependenciesModelFromJson(json);


  Map<String, dynamic> toJson() => _$LanguageDependenciesModelToJson(this);

  LanguageDependenciesModel(this.parentIdentifier, this.id, this.name,
      this.version, this.description, this.type);
}

enum ResourceType {
  CLASS,
  TEMPLATE,
  PROJECT,
  MAVEN_PROJECT,
  GRADLE_PROJECT,
  DEPENDENCY,
  NEW
}

enum ResourceVisibility {
  PUBLIC,
  PRIVATE
}

@JsonSerializable(createToJson: true)
class License {
  String key;
  String name;
  String spdxID;
  String url;

  factory License.fromJson(Map<String, dynamic> json) =>
      _$LicenseFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseToJson(this);

  License(this.key, this.name, this.spdxID, this.url);
}