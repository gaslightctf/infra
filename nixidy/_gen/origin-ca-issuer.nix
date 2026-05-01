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
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuer" = {

      options = {
        "apiVersion" = mkOption {
          description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec is the desired state of the ClusterOriginIssuer resource.";
          type = (types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpec"));
        };
        "status" = mkOption {
          description = "Status of the ClusterOriginIssuer. This is set and managed automatically.";
          type = (types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpec" = {

      options = {
        "auth" = mkOption {
          description = "Auth configures how to authenticate with the Cloudflare API.";
          type = (submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuth");
        };
        "requestType" = mkOption {
          description = "RequestType is the signature algorithm Cloudflare should use to sign the certificate.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuth" = {

      options = {
        "serviceKeyRef" = mkOption {
          description = "ServiceKeyRef authenticates with an API Service Key (the \"Origin CA Key\").\nDeprecated: 2026-03-19.";
          type = (
            types.nullOr (
              submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuthServiceKeyRef"
            )
          );
        };
        "tokenRef" = mkOption {
          description = "TokenRef authenticates with an API Token.";
          type = (
            types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuthTokenRef")
          );
        };
      };

      config = {
        "serviceKeyRef" = mkOverride 1002 null;
        "tokenRef" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuthServiceKeyRef" = {

      options = {
        "key" = mkOption {
          description = "Key of the secret to select from. Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the secret in the issuer's namespace to select. If a cluster-scoped\nissuer, the secret is selected from the \"cluster resource namespace\" configured\non the controller.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerSpecAuthTokenRef" = {

      options = {
        "key" = mkOption {
          description = "Key of the secret to select from. Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the secret in the issuer's namespace to select. If a cluster-scoped\nissuer, the secret is selected from the \"cluster resource namespace\" configured\non the controller.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerStatus" = {

      options = {
        "conditions" = mkOption {
          description = "List of status conditions to indicate the status of an Issuer.\nKnown condition types are `Ready`.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerStatusConditions")
            )
          );
        };
      };

      config = {
        "conditions" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuerStatusConditions" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "lastTransitionTime is the last time the condition transitioned from one status to another.\nThis should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.";
          type = types.str;
        };
        "message" = mkOption {
          description = "message is a human readable message indicating details about the transition.\nThis may be an empty string.";
          type = types.str;
        };
        "observedGeneration" = mkOption {
          description = "observedGeneration represents the .metadata.generation that the condition was set based upon.\nFor instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date\nwith respect to the current state of the instance.";
          type = (types.nullOr types.int);
        };
        "reason" = mkOption {
          description = "reason contains a programmatic identifier indicating the reason for the condition's last transition.\nProducers of specific condition types may define expected values and meanings for this field,\nand whether the values are considered a guaranteed API.\nThe value should be a CamelCase string.\nThis field may not be empty.";
          type = types.str;
        };
        "status" = mkOption {
          description = "status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "type of condition in CamelCase or in foo.example.com/CamelCase.";
          type = types.str;
        };
      };

      config = {
        "observedGeneration" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuer" = {

      options = {
        "apiVersion" = mkOption {
          description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Desired state of the OriginIssuer resource";
          type = (types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpec"));
        };
        "status" = mkOption {
          description = "Status of the OriginIssuer. This is set and managed automatically.";
          type = (types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpec" = {

      options = {
        "auth" = mkOption {
          description = "Auth configures how to authenticate with the Cloudflare API.";
          type = (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuth");
        };
        "requestType" = mkOption {
          description = "RequestType is the signature algorithm Cloudflare should use to sign the certificate.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuth" = {

      options = {
        "serviceKeyRef" = mkOption {
          description = "ServiceKeyRef authenticates with an API Service Key (the \"Origin CA Key\").\nDeprecated: 2026-03-19.";
          type = (
            types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuthServiceKeyRef")
          );
        };
        "tokenRef" = mkOption {
          description = "TokenRef authenticates with an API Token.";
          type = (
            types.nullOr (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuthTokenRef")
          );
        };
      };

      config = {
        "serviceKeyRef" = mkOverride 1002 null;
        "tokenRef" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuthServiceKeyRef" = {

      options = {
        "key" = mkOption {
          description = "Key of the secret to select from. Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the secret in the issuer's namespace to select. If a cluster-scoped\nissuer, the secret is selected from the \"cluster resource namespace\" configured\non the controller.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerSpecAuthTokenRef" = {

      options = {
        "key" = mkOption {
          description = "Key of the secret to select from. Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the secret in the issuer's namespace to select. If a cluster-scoped\nissuer, the secret is selected from the \"cluster resource namespace\" configured\non the controller.";
          type = types.str;
        };
      };

      config = { };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerStatus" = {

      options = {
        "conditions" = mkOption {
          description = "List of status conditions to indicate the status of an Issuer.\nKnown condition types are `Ready`.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "cert-manager.k8s.cloudflare.com.v1.OriginIssuerStatusConditions")
            )
          );
        };
      };

      config = {
        "conditions" = mkOverride 1002 null;
      };

    };
    "cert-manager.k8s.cloudflare.com.v1.OriginIssuerStatusConditions" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "lastTransitionTime is the last time the condition transitioned from one status to another.\nThis should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.";
          type = types.str;
        };
        "message" = mkOption {
          description = "message is a human readable message indicating details about the transition.\nThis may be an empty string.";
          type = types.str;
        };
        "observedGeneration" = mkOption {
          description = "observedGeneration represents the .metadata.generation that the condition was set based upon.\nFor instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date\nwith respect to the current state of the instance.";
          type = (types.nullOr types.int);
        };
        "reason" = mkOption {
          description = "reason contains a programmatic identifier indicating the reason for the condition's last transition.\nProducers of specific condition types may define expected values and meanings for this field,\nand whether the values are considered a guaranteed API.\nThe value should be a CamelCase string.\nThis field may not be empty.";
          type = types.str;
        };
        "status" = mkOption {
          description = "status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "type of condition in CamelCase or in foo.example.com/CamelCase.";
          type = types.str;
        };
      };

      config = {
        "observedGeneration" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "cert-manager.k8s.cloudflare.com"."v1"."ClusterOriginIssuer" = mkOption {
        description = "A ClusterOriginIssuer represents the Cloudflare Origin CA as an external cert-manager issuer.\nIt is scoped to a single namespace, so it can be used only by resources in the same\nnamespace.";
        type = (
          types.attrsOf (
            submoduleForDefinition "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuer"
              "clusteroriginissuers"
              "ClusterOriginIssuer"
              "cert-manager.k8s.cloudflare.com"
              "v1"
          )
        );
        default = { };
      };
      "cert-manager.k8s.cloudflare.com"."v1"."OriginIssuer" = mkOption {
        description = "An OriginIssuer represents the Cloudflare Origin CA as an external cert-manager issuer.\nIt is scoped to a single namespace, so it can be used only by resources in the same\nnamespace.";
        type = (
          types.attrsOf (
            submoduleForDefinition "cert-manager.k8s.cloudflare.com.v1.OriginIssuer" "originissuers"
              "OriginIssuer"
              "cert-manager.k8s.cloudflare.com"
              "v1"
          )
        );
        default = { };
      };

    }
    // {
      "clusterOriginIssuers" = mkOption {
        description = "A ClusterOriginIssuer represents the Cloudflare Origin CA as an external cert-manager issuer.\nIt is scoped to a single namespace, so it can be used only by resources in the same\nnamespace.";
        type = (
          types.attrsOf (
            submoduleForDefinition "cert-manager.k8s.cloudflare.com.v1.ClusterOriginIssuer"
              "clusteroriginissuers"
              "ClusterOriginIssuer"
              "cert-manager.k8s.cloudflare.com"
              "v1"
          )
        );
        default = { };
      };
      "originIssuers" = mkOption {
        description = "An OriginIssuer represents the Cloudflare Origin CA as an external cert-manager issuer.\nIt is scoped to a single namespace, so it can be used only by resources in the same\nnamespace.";
        type = (
          types.attrsOf (
            submoduleForDefinition "cert-manager.k8s.cloudflare.com.v1.OriginIssuer" "originissuers"
              "OriginIssuer"
              "cert-manager.k8s.cloudflare.com"
              "v1"
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
        name = "clusteroriginissuers";
        group = "cert-manager.k8s.cloudflare.com";
        version = "v1";
        kind = "ClusterOriginIssuer";
        attrName = "clusterOriginIssuers";
      }
      {
        name = "originissuers";
        group = "cert-manager.k8s.cloudflare.com";
        version = "v1";
        kind = "OriginIssuer";
        attrName = "originIssuers";
      }
    ];

    resources = {
      "cert-manager.k8s.cloudflare.com"."v1"."ClusterOriginIssuer" =
        mkAliasDefinitions
          options.resources."clusterOriginIssuers";
      "cert-manager.k8s.cloudflare.com"."v1"."OriginIssuer" =
        mkAliasDefinitions
          options.resources."originIssuers";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "cert-manager.k8s.cloudflare.com";
        version = "v1";
        kind = "OriginIssuer";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
