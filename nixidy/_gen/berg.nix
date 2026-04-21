# This file was generated with nixidy resource generator, do not edit.
{
  lib,
  options,
  config,
  ...
}:

with lib;

let
  hasAttrNotNull = attr: set: hasAttr attr set && set.${attr} != null;

  attrsToList =
    values:
    if values != null then
      sort (
        a: b:
        if (hasAttrNotNull "_priority" a && hasAttrNotNull "_priority" b) then
          a._priority < b._priority
        else
          false
      ) (mapAttrsToList (n: v: v) values)
    else
      values;

  getDefaults =
    resource: group: version: kind:
    catAttrs "default" (
      filter (
        default:
        (default.resource == null || default.resource == resource)
        && (default.group == null || default.group == group)
        && (default.version == null || default.version == version)
        && (default.kind == null || default.kind == kind)
      ) config.defaults
    );

  types = lib.types // rec {
    str = mkOptionType {
      name = "str";
      description = "string";
      check = isString;
      merge = mergeEqualOption;
    };

    # Either value of type `finalType` or `coercedType`, the latter is
    # converted to `finalType` using `coerceFunc`.
    coercedTo =
      coercedType: coerceFunc: finalType:
      mkOptionType rec {
        inherit (finalType) getSubOptions getSubModules;

        name = "coercedTo";
        description = "${finalType.description} or ${coercedType.description}";
        check = x: finalType.check x || coercedType.check x;
        merge =
          loc: defs:
          let
            coerceVal =
              val:
              if finalType.check val then
                val
              else
                let
                  coerced = coerceFunc val;
                in
                assert finalType.check coerced;
                coerced;

          in
          finalType.merge loc (map (def: def // { value = coerceVal def.value; }) defs);
        substSubModules = m: coercedTo coercedType coerceFunc (finalType.substSubModules m);
        typeMerge = t1: t2: null;
        functor = (defaultFunctor name) // {
          wrapped = finalType;
        };
      };
  };

  mkOptionDefault = mkOverride 1001;

  mergeValuesByKey =
    attrMergeKey: listMergeKeys: values:
    listToAttrs (
      imap0 (
        i: value:
        nameValuePair (
          if hasAttr attrMergeKey value then
            if isAttrs value.${attrMergeKey} then
              toString value.${attrMergeKey}.content
            else
              (toString value.${attrMergeKey})
          else
            # generate merge key for list elements if it's not present
            "__kubenix_list_merge_key_"
            + (concatStringsSep "" (
              map (
                key: if isAttrs value.${key} then toString value.${key}.content else (toString value.${key})
              ) listMergeKeys
            ))
        ) (value // { _priority = i; })
      ) values
    );

  submoduleOf =
    ref:
    types.submodule (
      { name, ... }:
      {
        options = definitions."${ref}".options or { };
        config = definitions."${ref}".config or { };
      }
    );

  globalSubmoduleOf =
    ref:
    types.submodule (
      { name, ... }:
      {
        options = config.definitions."${ref}".options or { };
        config = config.definitions."${ref}".config or { };
      }
    );

  submoduleWithMergeOf =
    ref: mergeKey:
    types.submodule (
      { name, ... }:
      let
        convertName =
          name: if definitions."${ref}".options.${mergeKey}.type == types.int then toInt name else name;
      in
      {
        options = definitions."${ref}".options // {
          # position in original array
          _priority = mkOption {
            type = types.nullOr types.int;
            default = null;
            internal = true;
          };
        };
        config = definitions."${ref}".config // {
          ${mergeKey} = mkOverride 1002 (
            # use name as mergeKey only if it is not coming from mergeValuesByKey
            if (!hasPrefix "__kubenix_list_merge_key_" name) then convertName name else null
          );
        };
      }
    );

  submoduleForDefinition =
    ref: resource: kind: group: version:
    let
      apiVersion = if group == "core" then version else "${group}/${version}";
    in
    types.submodule (
      { name, ... }:
      {
        inherit (definitions."${ref}") options;

        imports = getDefaults resource group version kind;
        config = mkMerge [
          definitions."${ref}".config
          {
            kind = mkOptionDefault kind;
            apiVersion = mkOptionDefault apiVersion;

            # metdata.name cannot use option default, due deep config
            metadata.name = mkOptionDefault name;
          }
        ];
      }
    );

  coerceAttrsOfSubmodulesToListByKey =
    ref: attrMergeKey: listMergeKeys:
    (types.coercedTo (types.listOf (submoduleOf ref)) (mergeValuesByKey attrMergeKey listMergeKeys) (
      types.attrsOf (submoduleWithMergeOf ref attrMergeKey)
    ));

  definitions = {
    "berg.norelect.ch.v1.Challenge" = {

      options = {
        "apiVersion" = mkOption {
          description = "\nAPIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources\n";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "\nKind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds\n";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpec" = {

      options = {
        "allowOutboundTraffic" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "attachments" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf (submoduleOf "berg.norelect.ch.v1.ChallengeSpecAttachments")));
        };
        "author" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "categories" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "containers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainers")));
        };
        "description" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "difficulty" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "displayName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "dynamicFlagMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "event" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "flag" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "flagFormat" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hideUntil" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tags" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "allowOutboundTraffic" = mkOverride 1002 null;
        "attachments" = mkOverride 1002 null;
        "author" = mkOverride 1002 null;
        "categories" = mkOverride 1002 null;
        "containers" = mkOverride 1002 null;
        "description" = mkOverride 1002 null;
        "difficulty" = mkOverride 1002 null;
        "displayName" = mkOverride 1002 null;
        "dynamicFlagMode" = mkOverride 1002 null;
        "event" = mkOverride 1002 null;
        "flag" = mkOverride 1002 null;
        "flagFormat" = mkOverride 1002 null;
        "hideUntil" = mkOverride 1002 null;
        "tags" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecAttachments" = {

      options = {
        "downloadImage" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "downloadImageInsecure" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "downloadImagePullSecret" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "downloadUrl" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fileName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "downloadImage" = mkOverride 1002 null;
        "downloadImageInsecure" = mkOverride 1002 null;
        "downloadImagePullSecret" = mkOverride 1002 null;
        "downloadUrl" = mkOverride 1002 null;
        "fileName" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainers" = {

      options = {
        "additionalCapabilities" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dynamicFlag" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlag"));
        };
        "egressBandwidth" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "environment" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "hostname" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "ingressBandwidth" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "berg.norelect.ch.v1.ChallengeSpecContainersPorts" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "resourceLimits" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersResourceLimits"));
        };
        "resourceRequests" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersResourceRequests"));
        };
        "runtimeClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "additionalCapabilities" = mkOverride 1002 null;
        "dynamicFlag" = mkOverride 1002 null;
        "egressBandwidth" = mkOverride 1002 null;
        "environment" = mkOverride 1002 null;
        "hostname" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "ingressBandwidth" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resourceLimits" = mkOverride 1002 null;
        "resourceRequests" = mkOverride 1002 null;
        "runtimeClassName" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlag" = {

      options = {
        "content" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagContent"));
        };
        "env" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagEnv"));
        };
        "executable" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagExecutable")
          );
        };
      };

      config = {
        "content" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "executable" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagContent" = {

      options = {
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersDynamicFlagExecutable" = {

      options = {
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersPorts" = {

      options = {
        "appProtocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "appProtocol" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "port" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersResourceLimits" = {

      options = {
        "cpu" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "memory" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "cpu" = mkOverride 1002 null;
        "memory" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.ChallengeSpecContainersResourceRequests" = {

      options = {
        "cpu" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "memory" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "cpu" = mkOverride 1002 null;
        "memory" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.Page" = {

      options = {
        "apiVersion" = mkOption {
          description = "\nAPIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources\n";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "\nKind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds\n";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "berg.norelect.ch.v1.PageSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "berg.norelect.ch.v1.PageSpec" = {

      options = {
        "content" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "index" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.float));
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "title" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "content" = mkOverride 1002 null;
        "index" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "title" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "berg.norelect.ch"."v1"."Challenge" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "berg.norelect.ch.v1.Challenge" "challenges" "Challenge" "berg.norelect.ch"
              "v1"
          )
        );
        default = { };
      };
      "berg.norelect.ch"."v1"."Page" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "berg.norelect.ch.v1.Page" "pages" "Page" "berg.norelect.ch" "v1"
          )
        );
        default = { };
      };

    }
    // {
      "challenges" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "berg.norelect.ch.v1.Challenge" "challenges" "Challenge" "berg.norelect.ch"
              "v1"
          )
        );
        default = { };
      };
      "pages" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "berg.norelect.ch.v1.Page" "pages" "Page" "berg.norelect.ch" "v1"
          )
        );
        default = { };
      };

    };
  };

  config = {
    # expose resource definitions
    inherit definitions;

    # register resource types
    types = [
      {
        name = "challenges";
        group = "berg.norelect.ch";
        version = "v1";
        kind = "Challenge";
        attrName = "challenges";
      }
      {
        name = "pages";
        group = "berg.norelect.ch";
        version = "v1";
        kind = "Page";
        attrName = "pages";
      }
    ];

    resources = {
      "berg.norelect.ch"."v1"."Challenge" = mkAliasDefinitions options.resources."challenges";
      "berg.norelect.ch"."v1"."Page" = mkAliasDefinitions options.resources."pages";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "berg.norelect.ch";
        version = "v1";
        kind = "Challenge";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "berg.norelect.ch";
        version = "v1";
        kind = "Page";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
