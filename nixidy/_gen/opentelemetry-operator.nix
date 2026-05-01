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
    "opentelemetry.io.v1alpha1.Instrumentation" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpec"));
        };
        "status" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
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
    "opentelemetry.io.v1alpha1.InstrumentationSpec" = {

      options = {
        "apacheHttpd" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpd"));
        };
        "defaults" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDefaults"));
        };
        "dotnet" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnet"));
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecEnv" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "exporter" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecExporter"));
        };
        "go" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGo"));
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "java" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJava"));
        };
        "nginx" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginx"));
        };
        "nodejs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejs"));
        };
        "propagators" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "python" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPython"));
        };
        "resource" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecResource"));
        };
        "sampler" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecSampler"));
        };
      };

      config = {
        "apacheHttpd" = mkOverride 1002 null;
        "defaults" = mkOverride 1002 null;
        "dotnet" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "exporter" = mkOverride 1002 null;
        "go" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "java" = mkOverride 1002 null;
        "nginx" = mkOverride 1002 null;
        "nodejs" = mkOverride 1002 null;
        "propagators" = mkOverride 1002 null;
        "python" = mkOverride 1002 null;
        "resource" = mkOverride 1002 null;
        "sampler" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpd" = {

      options = {
        "attrs" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "configPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnv"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdResourceRequirements"
            )
          );
        };
        "version" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplate"
            )
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "attrs" = mkOverride 1002 null;
        "configPath" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrs" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdAttrsValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecApacheHttpdVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDefaults" = {

      options = {
        "useLabelsForResourceAttributes" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "useLabelsForResourceAttributes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnet" = {

      options = {
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnv" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetResourceRequirements")
          );
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecDotnetVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromFileKeyRef")
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromSecretKeyRef")
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecExporter" = {

      options = {
        "endpoint" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tls" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecExporterTls"));
        };
      };

      config = {
        "endpoint" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecExporterTls" = {

      options = {
        "ca_file" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "cert_file" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "configMapName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "key_file" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ca_file" = mkOverride 1002 null;
        "cert_file" = mkOverride 1002 null;
        "configMapName" = mkOverride 1002 null;
        "key_file" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGo" = {

      options = {
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnv" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoResourceRequirements")
          );
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromFileKeyRef")
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromSecretKeyRef")
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecGoResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecGoVolumeClaimTemplateSpecSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJava" = {

      options = {
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnv" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "extensions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaExtensions")
            )
          );
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resources" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaResources"));
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "extensions" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromFileKeyRef")
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaExtensions" = {

      options = {
        "dir" = mkOption {
          description = "";
          type = types.str;
        };
        "image" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecJavaResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecJavaVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginx" = {

      options = {
        "attrs" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrs" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "configFile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnv" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxResourceRequirements")
          );
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "attrs" = mkOverride 1002 null;
        "configFile" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrs" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxAttrsValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecNginxResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNginxVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejs" = {

      options = {
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnv" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsResourceRequirements")
          );
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecNodejsVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPython" = {

      options = {
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnv" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "resourceRequirements" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonResourceRequirements")
          );
        };
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplate")
          );
        };
        "volumeLimitSize" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "resourceRequirements" = mkOverride 1002 null;
        "volumeClaimTemplate" = mkOverride 1002 null;
        "volumeLimitSize" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonResourceRequirements" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.InstrumentationSpecPythonResourceRequirementsClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonResourceRequirementsClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpec");
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecPythonVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.InstrumentationSpecResource" = {

      options = {
        "addK8sUIDAttributes" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "resourceAttributes" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "addK8sUIDAttributes" = mkOverride 1002 null;
        "resourceAttributes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.InstrumentationSpecSampler" = {

      options = {
        "argument" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "argument" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridge" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpec"));
        };
        "status" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeStatus"));
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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpec" = {

      options = {
        "affinity" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinity"));
        };
        "capabilities" = mkOption {
          description = "";
          type = (types.attrsOf types.bool);
        };
        "componentsAllowed" = mkOption {
          description = "";
          type = (types.nullOr (types.loaOf types.str));
        };
        "description" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecDescription"));
        };
        "endpoint" = mkOption {
          description = "";
          type = types.str;
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnv" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFrom"))
          );
        };
        "headers" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "hostNetwork" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "ipFamilies" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "ipFamilyPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeSelector" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "podAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "podDnsConfig" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodDnsConfig"));
        };
        "podSecurityContext" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContext"));
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPorts" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "priorityClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "replicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "resources" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecResources"));
        };
        "securityContext" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContext"));
        };
        "serviceAccount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerations" = mkOption {
          description = "";
          type = (
            types.nullOr (types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTolerations"))
          );
        };
        "topologySpreadConstraints" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraints")
            )
          );
        };
        "upgradeStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumeMounts" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "volumes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumes" "name" [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "affinity" = mkOverride 1002 null;
        "componentsAllowed" = mkOverride 1002 null;
        "description" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "headers" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "ipFamilies" = mkOverride 1002 null;
        "ipFamilyPolicy" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "podAnnotations" = mkOverride 1002 null;
        "podDnsConfig" = mkOverride 1002 null;
        "podSecurityContext" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "priorityClassName" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
        "upgradeStrategy" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinity"));
        };
        "podAffinity" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinity"));
        };
        "podAntiAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinity")
          );
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "";
            type = (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecDescription" = {

      options = {
        "non_identifying_attributes" = mkOption {
          description = "";
          type = (types.attrsOf types.str);
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFromConfigMapRef"));
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFromSecretRef"));
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromConfigMapKeyRef")
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromFieldRef"));
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromFileKeyRef")
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromResourceFieldRef")
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromSecretKeyRef")
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodDnsConfig" = {

      options = {
        "nameservers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "options" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodDnsConfigOptions"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "searches" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "nameservers" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "searches" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodDnsConfigOptions" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextAppArmorProfile"
            )
          );
        };
        "fsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "fsGroupChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSeccompProfile"
            )
          );
        };
        "supplementalGroups" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
        "supplementalGroupsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sysctls" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "appArmorProfile" = mkOverride 1002 null;
        "fsGroup" = mkOverride 1002 null;
        "fsGroupChangePolicy" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxChangePolicy" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
        "supplementalGroupsPolicy" = mkOverride 1002 null;
        "sysctls" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextSysctls" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPodSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecPorts" = {

      options = {
        "appProtocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "targetPort" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "appProtocol" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "nodePort" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "targetPort" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.OpAMPBridgeSpecResourcesClaims" "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextAppArmorProfile")
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextCapabilities")
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextSeLinuxOptions")
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextSeccompProfile")
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextWindowsOptions")
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTolerations" = {

      options = {
        "effect" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraintsLabelSelector"
            )
          );
        };
        "matchLabelKeys" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "maxSkew" = mkOption {
          description = "";
          type = types.int;
        };
        "minDomains" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "nodeAffinityPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeTaintsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "topologyKey" = mkOption {
          description = "";
          type = types.str;
        };
        "whenUnsatisfiable" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "matchLabelKeys" = mkOverride 1002 null;
        "minDomains" = mkOverride 1002 null;
        "nodeAffinityPolicy" = mkOverride 1002 null;
        "nodeTaintsPolicy" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraintsLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraintsLabelSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecTopologySpreadConstraintsLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumes" = {

      options = {
        "awsElasticBlockStore" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAwsElasticBlockStore")
          );
        };
        "azureDisk" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAzureDisk"));
        };
        "azureFile" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAzureFile"));
        };
        "cephfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCephfs"));
        };
        "cinder" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCinder"));
        };
        "configMap" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesConfigMap"));
        };
        "csi" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCsi"));
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPI"));
        };
        "emptyDir" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEmptyDir"));
        };
        "ephemeral" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeral"));
        };
        "fc" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFc"));
        };
        "flexVolume" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlexVolume"));
        };
        "flocker" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlocker"));
        };
        "gcePersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGcePersistentDisk")
          );
        };
        "gitRepo" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGitRepo"));
        };
        "glusterfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGlusterfs"));
        };
        "hostPath" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesHostPath"));
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesImage"));
        };
        "iscsi" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesIscsi"));
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "nfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesNfs"));
        };
        "persistentVolumeClaim" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPersistentVolumeClaim")
          );
        };
        "photonPersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPhotonPersistentDisk")
          );
        };
        "portworxVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPortworxVolume")
          );
        };
        "projected" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjected"));
        };
        "quobyte" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesQuobyte"));
        };
        "rbd" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesRbd"));
        };
        "scaleIO" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesScaleIO"));
        };
        "secret" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesSecret"));
        };
        "storageos" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesStorageos"));
        };
        "vsphereVolume" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesVsphereVolume"));
        };
      };

      config = {
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "csi" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "emptyDir" = mkOverride 1002 null;
        "ephemeral" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "gitRepo" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeClaim" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "projected" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAwsElasticBlockStore" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAzureDisk" = {

      options = {
        "cachingMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "diskName" = mkOption {
          description = "";
          type = types.str;
        };
        "diskURI" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "cachingMode" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesAzureFile" = {

      options = {
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = types.str;
        };
        "shareName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCephfs" = {

      options = {
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretFile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCephfsSecretRef")
          );
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretFile" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCephfsSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCinder" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCinderSecretRef")
          );
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCinderSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesConfigMap" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesConfigMapItems")
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCsi" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePublishSecretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCsiNodePublishSecretRef")
          );
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeAttributes" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "nodePublishSecretRef" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "volumeAttributes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesCsiNodePublishSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPI" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItems")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesDownwardAPIItemsResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEmptyDir" = {

      options = {
        "medium" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sizeLimit" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "medium" = mkOverride 1002 null;
        "sizeLimit" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeral" = {

      options = {
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplate"
            )
          );
        };
      };

      config = {
        "volumeClaimTemplate" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFc" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "targetWWNs" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "wwids" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "lun" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "targetWWNs" = mkOverride 1002 null;
        "wwids" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlexVolume" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlexVolumeSecretRef")
          );
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlexVolumeSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesFlocker" = {

      options = {
        "datasetName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "datasetUUID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "datasetName" = mkOverride 1002 null;
        "datasetUUID" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGcePersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "pdName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGitRepo" = {

      options = {
        "directory" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "repository" = mkOption {
          description = "";
          type = types.str;
        };
        "revision" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "directory" = mkOverride 1002 null;
        "revision" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesGlusterfs" = {

      options = {
        "endpoints" = mkOption {
          description = "";
          type = types.str;
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesHostPath" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesImage" = {

      options = {
        "pullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "reference" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pullPolicy" = mkOverride 1002 null;
        "reference" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesIscsi" = {

      options = {
        "chapAuthDiscovery" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "chapAuthSession" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "initiatorName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "iqn" = mkOption {
          description = "";
          type = types.str;
        };
        "iscsiInterface" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = types.int;
        };
        "portals" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesIscsiSecretRef")
          );
        };
        "targetPortal" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "chapAuthDiscovery" = mkOverride 1002 null;
        "chapAuthSession" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "initiatorName" = mkOverride 1002 null;
        "iscsiInterface" = mkOverride 1002 null;
        "portals" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesIscsiSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesNfs" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "server" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPersistentVolumeClaim" = {

      options = {
        "claimName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPhotonPersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "pdID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesPortworxVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjected" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSources")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "sources" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSources" = {

      options = {
        "clusterTrustBundle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundle"
            )
          );
        };
        "configMap" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesConfigMap"
            )
          );
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPI"
            )
          );
        };
        "podCertificate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesPodCertificate"
            )
          );
        };
        "secret" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesSecret")
          );
        };
        "serviceAccountToken" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesServiceAccountToken"
            )
          );
        };
      };

      config = {
        "clusterTrustBundle" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "podCertificate" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "serviceAccountToken" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundle" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "signerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "signerName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesConfigMap" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesConfigMapItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPI" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef" =
      {

        options = {
          "containerName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "divisor" = mkOption {
            description = "";
            type = (types.nullOr (types.either types.int types.str));
          };
          "resource" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "containerName" = mkOverride 1002 null;
          "divisor" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesPodCertificate" = {

      options = {
        "certificateChainPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "credentialBundlePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyType" = mkOption {
          description = "";
          type = types.str;
        };
        "maxExpirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "signerName" = mkOption {
          description = "";
          type = types.str;
        };
        "userAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "certificateChainPath" = mkOverride 1002 null;
        "credentialBundlePath" = mkOverride 1002 null;
        "keyPath" = mkOverride 1002 null;
        "maxExpirationSeconds" = mkOverride 1002 null;
        "userAnnotations" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesSecret" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesSecretItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesProjectedSourcesServiceAccountToken" = {

      options = {
        "audience" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "expirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "audience" = mkOverride 1002 null;
        "expirationSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesQuobyte" = {

      options = {
        "group" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "registry" = mkOption {
          description = "";
          type = types.str;
        };
        "tenant" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volume" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "tenant" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesRbd" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "";
          type = types.str;
        };
        "keyring" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "pool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesRbdSecretRef"));
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "keyring" = mkOverride 1002 null;
        "pool" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesRbdSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesScaleIO" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gateway" = mkOption {
          description = "";
          type = types.str;
        };
        "protectionDomain" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesScaleIOSecretRef");
        };
        "sslEnabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "storageMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "system" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "protectionDomain" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "sslEnabled" = mkOverride 1002 null;
        "storageMode" = mkOverride 1002 null;
        "storagePool" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesScaleIOSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesSecret" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesSecretItems")
            )
          );
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesStorageos" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesStorageosSecretRef")
          );
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesStorageosSecretRef" = {

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
    "opentelemetry.io.v1alpha1.OpAMPBridgeSpecVolumesVsphereVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumePath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "storagePolicyID" = mkOverride 1002 null;
        "storagePolicyName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.OpAMPBridgeStatus" = {

      options = {
        "version" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "version" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocator" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpec"));
        };
        "status" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorStatus"));
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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpec" = {

      options = {
        "additionalContainers" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainers"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "affinity" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinity"));
        };
        "allocationStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "collectorNotReadyGracePeriod" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "dnsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnv" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFrom"))
          );
        };
        "filterStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "global" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "hostAliases" = mkOption {
          description = "";
          type = (
            types.nullOr (types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecHostAliases"))
          );
        };
        "hostNetwork" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "hostPID" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "hostUsers" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "initContainers" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainers"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "ipFamilies" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "ipFamilyPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecycle"));
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbe"));
        };
        "managementState" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "networkPolicy" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecNetworkPolicy"));
        };
        "nodeSelector" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "observability" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecObservability"));
        };
        "podAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "podDisruptionBudget" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDisruptionBudget")
          );
        };
        "podDnsConfig" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDnsConfig"));
        };
        "podSecurityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContext")
          );
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecPorts" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "priorityClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "prometheusCR" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCR"));
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbe"));
        };
        "replicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "resources" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecResources"));
        };
        "scrapeConfigs" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.attrs));
        };
        "securityContext" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContext"));
        };
        "serviceAccount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "shareProcessNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tolerations" = mkOption {
          description = "";
          type = (
            types.nullOr (types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecTolerations"))
          );
        };
        "topologySpreadConstraints" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraints")
            )
          );
        };
        "trafficDistribution" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumeMounts"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "volumes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumes" "name" [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "additionalContainers" = mkOverride 1002 null;
        "affinity" = mkOverride 1002 null;
        "allocationStrategy" = mkOverride 1002 null;
        "args" = mkOverride 1002 null;
        "collectorNotReadyGracePeriod" = mkOverride 1002 null;
        "dnsPolicy" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "filterStrategy" = mkOverride 1002 null;
        "global" = mkOverride 1002 null;
        "hostAliases" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "hostPID" = mkOverride 1002 null;
        "hostUsers" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "initContainers" = mkOverride 1002 null;
        "ipFamilies" = mkOverride 1002 null;
        "ipFamilyPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "managementState" = mkOverride 1002 null;
        "networkPolicy" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "observability" = mkOverride 1002 null;
        "podAnnotations" = mkOverride 1002 null;
        "podDisruptionBudget" = mkOverride 1002 null;
        "podDnsConfig" = mkOverride 1002 null;
        "podSecurityContext" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "priorityClassName" = mkOverride 1002 null;
        "prometheusCR" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "scrapeConfigs" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "shareProcessNamespace" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
        "trafficDistribution" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainers" = {

      options = {
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFrom"
              )
            )
          );
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecycle"
            )
          );
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbe"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResizePolicy"
              )
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResources"
            )
          );
        };
        "restartPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbe"
            )
          );
        };
        "stdin" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextAppArmorProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAdditionalContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinity")
          );
        };
        "podAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinity")
          );
        };
        "podAntiAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinity")
          );
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "";
            type = (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFromConfigMapRef")
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFromSecretRef"));
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromFileKeyRef")
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromSecretKeyRef")
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecHostAliases" = {

      options = {
        "hostnames" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "ip" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "hostnames" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainers" = {

      options = {
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFrom")
            )
          );
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecycle")
          );
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbe"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResizePolicy")
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResources")
          );
        };
        "restartPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbe")
          );
        };
        "stdin" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecInitContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStart")
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStop"));
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartExec")
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartHttpGet")
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartSleep")
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopExec")
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopHttpGet")
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopSleep")
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopTcpSocket")
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeExec")
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeGrpc")
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeHttpGet")
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeTcpSocket")
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecNetworkPolicy" = {

      options = {
        "enabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecObservability" = {

      options = {
        "metrics" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecObservabilityMetrics")
          );
        };
      };

      config = {
        "metrics" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecObservabilityMetrics" = {

      options = {
        "disablePrometheusAnnotations" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "enableMetrics" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "extraLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "disablePrometheusAnnotations" = mkOverride 1002 null;
        "enableMetrics" = mkOverride 1002 null;
        "extraLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDisruptionBudget" = {

      options = {
        "maxUnavailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "minAvailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxUnavailable" = mkOverride 1002 null;
        "minAvailable" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDnsConfig" = {

      options = {
        "nameservers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "options" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDnsConfigOptions"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "searches" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "nameservers" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "searches" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodDnsConfigOptions" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextAppArmorProfile"
            )
          );
        };
        "fsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "fsGroupChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSeccompProfile"
            )
          );
        };
        "supplementalGroups" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
        "supplementalGroupsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sysctls" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "appArmorProfile" = mkOverride 1002 null;
        "fsGroup" = mkOverride 1002 null;
        "fsGroupChangePolicy" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxChangePolicy" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
        "supplementalGroupsPolicy" = mkOverride 1002 null;
        "sysctls" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextSysctls" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPodSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPorts" = {

      options = {
        "appProtocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "targetPort" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "appProtocol" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "nodePort" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "targetPort" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCR" = {

      options = {
        "allowNamespaces" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "denyNamespaces" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "enabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "evaluationInterval" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "podMonitorNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorNamespaceSelector"
            )
          );
        };
        "podMonitorSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorSelector"
            )
          );
        };
        "probeNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeNamespaceSelector"
            )
          );
        };
        "probeSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeSelector")
          );
        };
        "scrapeClasses" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.attrs));
        };
        "scrapeConfigNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigNamespaceSelector"
            )
          );
        };
        "scrapeConfigSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigSelector"
            )
          );
        };
        "scrapeInterval" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "scrapeProtocols" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "serviceMonitorNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorNamespaceSelector"
            )
          );
        };
        "serviceMonitorSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorSelector"
            )
          );
        };
      };

      config = {
        "allowNamespaces" = mkOverride 1002 null;
        "denyNamespaces" = mkOverride 1002 null;
        "enabled" = mkOverride 1002 null;
        "evaluationInterval" = mkOverride 1002 null;
        "podMonitorNamespaceSelector" = mkOverride 1002 null;
        "podMonitorSelector" = mkOverride 1002 null;
        "probeNamespaceSelector" = mkOverride 1002 null;
        "probeSelector" = mkOverride 1002 null;
        "scrapeClasses" = mkOverride 1002 null;
        "scrapeConfigNamespaceSelector" = mkOverride 1002 null;
        "scrapeConfigSelector" = mkOverride 1002 null;
        "scrapeInterval" = mkOverride 1002 null;
        "scrapeProtocols" = mkOverride 1002 null;
        "serviceMonitorNamespaceSelector" = mkOverride 1002 null;
        "serviceMonitorSelector" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorNamespaceSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorNamespaceSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRPodMonitorSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeNamespaceSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeNamespaceSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRProbeSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigNamespaceSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigNamespaceSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRScrapeConfigSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorNamespaceSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorNamespaceSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecPrometheusCRServiceMonitorSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeExec")
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeGrpc")
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeHttpGet")
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeTcpSocket")
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1alpha1.TargetAllocatorSpecResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecTolerations" = {

      options = {
        "effect" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraintsLabelSelector"
            )
          );
        };
        "matchLabelKeys" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "maxSkew" = mkOption {
          description = "";
          type = types.int;
        };
        "minDomains" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "nodeAffinityPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeTaintsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "topologyKey" = mkOption {
          description = "";
          type = types.str;
        };
        "whenUnsatisfiable" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "matchLabelKeys" = mkOverride 1002 null;
        "minDomains" = mkOverride 1002 null;
        "nodeAffinityPolicy" = mkOverride 1002 null;
        "nodeTaintsPolicy" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraintsLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraintsLabelSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecTopologySpreadConstraintsLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumes" = {

      options = {
        "awsElasticBlockStore" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAwsElasticBlockStore"
            )
          );
        };
        "azureDisk" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAzureDisk"));
        };
        "azureFile" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAzureFile"));
        };
        "cephfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCephfs"));
        };
        "cinder" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCinder"));
        };
        "configMap" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesConfigMap"));
        };
        "csi" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCsi"));
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPI")
          );
        };
        "emptyDir" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEmptyDir"));
        };
        "ephemeral" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeral"));
        };
        "fc" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFc"));
        };
        "flexVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlexVolume")
          );
        };
        "flocker" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlocker"));
        };
        "gcePersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGcePersistentDisk")
          );
        };
        "gitRepo" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGitRepo"));
        };
        "glusterfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGlusterfs"));
        };
        "hostPath" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesHostPath"));
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesImage"));
        };
        "iscsi" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesIscsi"));
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "nfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesNfs"));
        };
        "persistentVolumeClaim" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPersistentVolumeClaim"
            )
          );
        };
        "photonPersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPhotonPersistentDisk"
            )
          );
        };
        "portworxVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPortworxVolume")
          );
        };
        "projected" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjected"));
        };
        "quobyte" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesQuobyte"));
        };
        "rbd" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesRbd"));
        };
        "scaleIO" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesScaleIO"));
        };
        "secret" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesSecret"));
        };
        "storageos" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesStorageos"));
        };
        "vsphereVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesVsphereVolume")
          );
        };
      };

      config = {
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "csi" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "emptyDir" = mkOverride 1002 null;
        "ephemeral" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "gitRepo" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeClaim" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "projected" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAwsElasticBlockStore" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAzureDisk" = {

      options = {
        "cachingMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "diskName" = mkOption {
          description = "";
          type = types.str;
        };
        "diskURI" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "cachingMode" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesAzureFile" = {

      options = {
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = types.str;
        };
        "shareName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCephfs" = {

      options = {
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretFile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCephfsSecretRef")
          );
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretFile" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCephfsSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCinder" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCinderSecretRef")
          );
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCinderSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesConfigMap" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesConfigMapItems")
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCsi" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePublishSecretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCsiNodePublishSecretRef"
            )
          );
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeAttributes" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "nodePublishSecretRef" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "volumeAttributes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesCsiNodePublishSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPI" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItems")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesDownwardAPIItemsResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEmptyDir" = {

      options = {
        "medium" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sizeLimit" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "medium" = mkOverride 1002 null;
        "sizeLimit" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeral" = {

      options = {
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplate"
            )
          );
        };
      };

      config = {
        "volumeClaimTemplate" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef" =
      {

        options = {
          "apiGroup" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "kind" = mkOption {
            description = "";
            type = types.str;
          };
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "namespace" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "apiGroup" = mkOverride 1002 null;
          "namespace" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFc" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "targetWWNs" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "wwids" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "lun" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "targetWWNs" = mkOverride 1002 null;
        "wwids" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlexVolume" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlexVolumeSecretRef")
          );
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlexVolumeSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesFlocker" = {

      options = {
        "datasetName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "datasetUUID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "datasetName" = mkOverride 1002 null;
        "datasetUUID" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGcePersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "pdName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGitRepo" = {

      options = {
        "directory" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "repository" = mkOption {
          description = "";
          type = types.str;
        };
        "revision" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "directory" = mkOverride 1002 null;
        "revision" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesGlusterfs" = {

      options = {
        "endpoints" = mkOption {
          description = "";
          type = types.str;
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesHostPath" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesImage" = {

      options = {
        "pullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "reference" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pullPolicy" = mkOverride 1002 null;
        "reference" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesIscsi" = {

      options = {
        "chapAuthDiscovery" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "chapAuthSession" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "initiatorName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "iqn" = mkOption {
          description = "";
          type = types.str;
        };
        "iscsiInterface" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = types.int;
        };
        "portals" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesIscsiSecretRef")
          );
        };
        "targetPortal" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "chapAuthDiscovery" = mkOverride 1002 null;
        "chapAuthSession" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "initiatorName" = mkOverride 1002 null;
        "iscsiInterface" = mkOverride 1002 null;
        "portals" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesIscsiSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesNfs" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "server" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPersistentVolumeClaim" = {

      options = {
        "claimName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPhotonPersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "pdID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesPortworxVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjected" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSources")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "sources" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSources" = {

      options = {
        "clusterTrustBundle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundle"
            )
          );
        };
        "configMap" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesConfigMap"
            )
          );
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPI"
            )
          );
        };
        "podCertificate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesPodCertificate"
            )
          );
        };
        "secret" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesSecret"
            )
          );
        };
        "serviceAccountToken" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesServiceAccountToken"
            )
          );
        };
      };

      config = {
        "clusterTrustBundle" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "podCertificate" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "serviceAccountToken" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundle" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "signerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "signerName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesConfigMap" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesConfigMapItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPI" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef" =
      {

        options = {
          "containerName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "divisor" = mkOption {
            description = "";
            type = (types.nullOr (types.either types.int types.str));
          };
          "resource" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "containerName" = mkOverride 1002 null;
          "divisor" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesPodCertificate" = {

      options = {
        "certificateChainPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "credentialBundlePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyType" = mkOption {
          description = "";
          type = types.str;
        };
        "maxExpirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "signerName" = mkOption {
          description = "";
          type = types.str;
        };
        "userAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "certificateChainPath" = mkOverride 1002 null;
        "credentialBundlePath" = mkOverride 1002 null;
        "keyPath" = mkOverride 1002 null;
        "maxExpirationSeconds" = mkOverride 1002 null;
        "userAnnotations" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesSecret" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesSecretItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesProjectedSourcesServiceAccountToken" = {

      options = {
        "audience" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "expirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "audience" = mkOverride 1002 null;
        "expirationSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesQuobyte" = {

      options = {
        "group" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "registry" = mkOption {
          description = "";
          type = types.str;
        };
        "tenant" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volume" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "tenant" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesRbd" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "";
          type = types.str;
        };
        "keyring" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "pool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesRbdSecretRef")
          );
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "keyring" = mkOverride 1002 null;
        "pool" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesRbdSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesScaleIO" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gateway" = mkOption {
          description = "";
          type = types.str;
        };
        "protectionDomain" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesScaleIOSecretRef");
        };
        "sslEnabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "storageMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "system" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "protectionDomain" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "sslEnabled" = mkOverride 1002 null;
        "storageMode" = mkOverride 1002 null;
        "storagePool" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesScaleIOSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesSecret" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesSecretItems")
            )
          );
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesStorageos" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesStorageosSecretRef")
          );
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesStorageosSecretRef" = {

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
    "opentelemetry.io.v1alpha1.TargetAllocatorSpecVolumesVsphereVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumePath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "storagePolicyID" = mkOverride 1002 null;
        "storagePolicyName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1alpha1.TargetAllocatorStatus" = {

      options = {
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "image" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollector" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpec"));
        };
        "status" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorStatus"));
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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpec" = {

      options = {
        "additionalContainers" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainers"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "affinity" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinity"));
        };
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "autoscaler" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscaler"));
        };
        "config" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfig");
        };
        "configVersions" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "configmaps" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfigmaps"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "daemonSetUpdateStrategy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDaemonSetUpdateStrategy"
            )
          );
        };
        "deploymentUpdateStrategy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDeploymentUpdateStrategy"
            )
          );
        };
        "dnsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnv" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFrom")
            )
          );
        };
        "hostAliases" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecHostAliases")
            )
          );
        };
        "hostNetwork" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "hostPID" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "hostUsers" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "httpRoute" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecHttpRoute"));
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "ingress" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngress"));
        };
        "initContainers" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainers"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "ipFamilies" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "ipFamilyPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecycle"));
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLivenessProbe")
          );
        };
        "managementState" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "networkPolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecNetworkPolicy")
          );
        };
        "nodeSelector" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "observability" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecObservability")
          );
        };
        "persistentVolumeClaimRetentionPolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPersistentVolumeClaimRetentionPolicy"
            )
          );
        };
        "podAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "podDisruptionBudget" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDisruptionBudget")
          );
        };
        "podDnsConfig" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDnsConfig")
          );
        };
        "podManagementPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "podSecurityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContext")
          );
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPorts" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "priorityClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecReadinessProbe")
          );
        };
        "replicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "resources" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecResources"));
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContext")
          );
        };
        "serviceAccount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "serviceName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "shareProcessNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "startupProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecStartupProbe")
          );
        };
        "targetAllocator" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocator")
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tolerations" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTolerations")
            )
          );
        };
        "topologySpreadConstraints" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraints"
              )
            )
          );
        };
        "trafficDistribution" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "upgradeStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeClaimTemplates" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplates")
            )
          );
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeMounts"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "volumes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumes"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "additionalContainers" = mkOverride 1002 null;
        "affinity" = mkOverride 1002 null;
        "args" = mkOverride 1002 null;
        "autoscaler" = mkOverride 1002 null;
        "configVersions" = mkOverride 1002 null;
        "configmaps" = mkOverride 1002 null;
        "daemonSetUpdateStrategy" = mkOverride 1002 null;
        "deploymentUpdateStrategy" = mkOverride 1002 null;
        "dnsPolicy" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "hostAliases" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "hostPID" = mkOverride 1002 null;
        "hostUsers" = mkOverride 1002 null;
        "httpRoute" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "ingress" = mkOverride 1002 null;
        "initContainers" = mkOverride 1002 null;
        "ipFamilies" = mkOverride 1002 null;
        "ipFamilyPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "managementState" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "networkPolicy" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "observability" = mkOverride 1002 null;
        "persistentVolumeClaimRetentionPolicy" = mkOverride 1002 null;
        "podAnnotations" = mkOverride 1002 null;
        "podDisruptionBudget" = mkOverride 1002 null;
        "podDnsConfig" = mkOverride 1002 null;
        "podManagementPolicy" = mkOverride 1002 null;
        "podSecurityContext" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "priorityClassName" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "serviceName" = mkOverride 1002 null;
        "shareProcessNamespace" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "targetAllocator" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
        "trafficDistribution" = mkOverride 1002 null;
        "upgradeStrategy" = mkOverride 1002 null;
        "volumeClaimTemplates" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainers" = {

      options = {
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFrom"
              )
            )
          );
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecycle"
            )
          );
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbe"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResizePolicy"
              )
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResources"
            )
          );
        };
        "restartPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbe"
            )
          );
        };
        "stdin" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromConfigMapKeyRef" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "name" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "optional" = mkOption {
            description = "";
            type = (types.nullOr types.bool);
          };
        };

        config = {
          "name" = mkOverride 1002 null;
          "optional" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromResourceFieldRef" =
      {

        options = {
          "containerName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "divisor" = mkOption {
            description = "";
            type = (types.nullOr (types.either types.int types.str));
          };
          "resource" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "containerName" = mkOverride 1002 null;
          "divisor" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersEnvValueFromSecretKeyRef" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "name" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "optional" = mkOption {
            description = "";
            type = (types.nullOr types.bool);
          };
        };

        config = {
          "name" = mkOverride 1002 null;
          "optional" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartHttpGet" =
      {

        options = {
          "host" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "httpHeaders" = mkOption {
            description = "";
            type = (
              types.nullOr (
                coerceAttrsOfSubmodulesToListByKey
                  "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartHttpGetHttpHeaders"
                  "name"
                  [ ]
              )
            );
            apply = attrsToList;
          };
          "path" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "port" = mkOption {
            description = "";
            type = (types.either types.int types.str);
          };
          "scheme" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "host" = mkOverride 1002 null;
          "httpHeaders" = mkOverride 1002 null;
          "path" = mkOverride 1002 null;
          "scheme" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePostStartTcpSocket" =
      {

        options = {
          "host" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "port" = mkOption {
            description = "";
            type = (types.either types.int types.str);
          };
        };

        config = {
          "host" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLifecyclePreStopTcpSocket" =
      {

        options = {
          "host" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "port" = mkOption {
            description = "";
            type = (types.either types.int types.str);
          };
        };

        config = {
          "host" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersRestartPolicyRulesExitCodes" =
      {

        options = {
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.int));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextAppArmorProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextCapabilities" =
      {

        options = {
          "add" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "drop" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "add" = mkOverride 1002 null;
          "drop" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextSeLinuxOptions" =
      {

        options = {
          "level" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "role" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "user" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "level" = mkOverride 1002 null;
          "role" = mkOverride 1002 null;
          "type" = mkOverride 1002 null;
          "user" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextSeccompProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersSecurityContextWindowsOptions" =
      {

        options = {
          "gmsaCredentialSpec" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "gmsaCredentialSpecName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "hostProcess" = mkOption {
            description = "";
            type = (types.nullOr types.bool);
          };
          "runAsUserName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "gmsaCredentialSpec" = mkOverride 1002 null;
          "gmsaCredentialSpecName" = mkOverride 1002 null;
          "hostProcess" = mkOverride 1002 null;
          "runAsUserName" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAdditionalContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinity")
          );
        };
        "podAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinity")
          );
        };
        "podAntiAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinity"
            )
          );
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "";
            type = (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscaler" = {

      options = {
        "behavior" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehavior")
          );
        };
        "maxReplicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "metrics" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetrics")
            )
          );
        };
        "minReplicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "targetCPUUtilization" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "targetMemoryUtilization" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "behavior" = mkOverride 1002 null;
        "maxReplicas" = mkOverride 1002 null;
        "metrics" = mkOverride 1002 null;
        "minReplicas" = mkOverride 1002 null;
        "targetCPUUtilization" = mkOverride 1002 null;
        "targetMemoryUtilization" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehavior" = {

      options = {
        "scaleDown" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleDown"
            )
          );
        };
        "scaleUp" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleUp"
            )
          );
        };
      };

      config = {
        "scaleDown" = mkOverride 1002 null;
        "scaleUp" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleDown" = {

      options = {
        "policies" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleDownPolicies"
              )
            )
          );
        };
        "selectPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "stabilizationWindowSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tolerance" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "policies" = mkOverride 1002 null;
        "selectPolicy" = mkOverride 1002 null;
        "stabilizationWindowSeconds" = mkOverride 1002 null;
        "tolerance" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleDownPolicies" = {

      options = {
        "periodSeconds" = mkOption {
          description = "";
          type = types.int;
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleUp" = {

      options = {
        "policies" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleUpPolicies"
              )
            )
          );
        };
        "selectPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "stabilizationWindowSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tolerance" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "policies" = mkOverride 1002 null;
        "selectPolicy" = mkOverride 1002 null;
        "stabilizationWindowSeconds" = mkOverride 1002 null;
        "tolerance" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerBehaviorScaleUpPolicies" = {

      options = {
        "periodSeconds" = mkOption {
          description = "";
          type = types.int;
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetrics" = {

      options = {
        "pods" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPods"
            )
          );
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "pods" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPods" = {

      options = {
        "metric" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetric"
          );
        };
        "target" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsTarget"
          );
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetric" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetricSelector"
            )
          );
        };
      };

      config = {
        "selector" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetricSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetricSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsMetricSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecAutoscalerMetricsPodsTarget" = {

      options = {
        "averageUtilization" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "averageValue" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "averageUtilization" = mkOverride 1002 null;
        "averageValue" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfig" = {

      options = {
        "connectors" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "exporters" = mkOption {
          description = "";
          type = types.attrs;
        };
        "extensions" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "processors" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "receivers" = mkOption {
          description = "";
          type = types.attrs;
        };
        "service" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfigService");
        };
      };

      config = {
        "connectors" = mkOverride 1002 null;
        "extensions" = mkOverride 1002 null;
        "processors" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfigService" = {

      options = {
        "extensions" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "pipelines" = mkOption {
          description = "";
          type = (types.attrsOf types.attrs);
        };
        "telemetry" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
      };

      config = {
        "extensions" = mkOverride 1002 null;
        "telemetry" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecConfigmaps" = {

      options = {
        "mountpath" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDaemonSetUpdateStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDaemonSetUpdateStrategyRollingUpdate"
            )
          );
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDaemonSetUpdateStrategyRollingUpdate" = {

      options = {
        "maxSurge" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "maxUnavailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxSurge" = mkOverride 1002 null;
        "maxUnavailable" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDeploymentUpdateStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDeploymentUpdateStrategyRollingUpdate"
            )
          );
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecDeploymentUpdateStrategyRollingUpdate" = {

      options = {
        "maxSurge" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "maxUnavailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxSurge" = mkOverride 1002 null;
        "maxUnavailable" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFromConfigMapRef")
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFromSecretRef")
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromFieldRef")
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecHostAliases" = {

      options = {
        "hostnames" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "ip" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "hostnames" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecHttpRoute" = {

      options = {
        "enabled" = mkOption {
          description = "";
          type = types.bool;
        };
        "gateway" = mkOption {
          description = "";
          type = types.str;
        };
        "gatewayNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostnames" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "gatewayNamespace" = mkOverride 1002 null;
        "hostnames" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngress" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "hostname" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "ingressClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "route" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngressRoute")
          );
        };
        "ruleType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tls" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngressTls")
            )
          );
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "hostname" = mkOverride 1002 null;
        "ingressClassName" = mkOverride 1002 null;
        "route" = mkOverride 1002 null;
        "ruleType" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngressRoute" = {

      options = {
        "termination" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "termination" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecIngressTls" = {

      options = {
        "hosts" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "secretName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hosts" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainers" = {

      options = {
        "args" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFrom"
              )
            )
          );
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecycle"
            )
          );
        };
        "livenessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbe"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "ports" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResizePolicy"
              )
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResources"
            )
          );
        };
        "restartPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbe"
            )
          );
        };
        "stdin" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "";
          type = types.str;
        };
        "values" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextAppArmorProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeTcpSocket"
            )
          );
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "service" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "value" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecInitContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStart")
          );
        };
        "preStop" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStop")
          );
        };
        "stopSignal" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopExec")
          );
        };
        "httpGet" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "";
          type = types.int;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecLivenessProbe" = {

      options = {
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecNetworkPolicy" = {

      options = {
        "enabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecObservability" = {

      options = {
        "metrics" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecObservabilityMetrics")
          );
        };
      };

      config = {
        "metrics" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecObservabilityMetrics" = {

      options = {
        "disablePrometheusAnnotations" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "enableMetrics" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "extraLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "disablePrometheusAnnotations" = mkOverride 1002 null;
        "enableMetrics" = mkOverride 1002 null;
        "extraLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPersistentVolumeClaimRetentionPolicy" = {

      options = {
        "whenDeleted" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "whenScaled" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "whenDeleted" = mkOverride 1002 null;
        "whenScaled" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDisruptionBudget" = {

      options = {
        "maxUnavailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "minAvailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxUnavailable" = mkOverride 1002 null;
        "minAvailable" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDnsConfig" = {

      options = {
        "nameservers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "options" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDnsConfigOptions"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "searches" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "nameservers" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "searches" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodDnsConfigOptions" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextAppArmorProfile"
            )
          );
        };
        "fsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "fsGroupChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSeccompProfile"
            )
          );
        };
        "supplementalGroups" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
        "supplementalGroupsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sysctls" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "appArmorProfile" = mkOverride 1002 null;
        "fsGroup" = mkOverride 1002 null;
        "fsGroupChangePolicy" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxChangePolicy" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
        "supplementalGroupsPolicy" = mkOverride 1002 null;
        "sysctls" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextSysctls" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPodSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecPorts" = {

      options = {
        "appProtocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePort" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "port" = mkOption {
          description = "";
          type = types.int;
        };
        "protocol" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "targetPort" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "appProtocol" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "nodePort" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "targetPort" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecReadinessProbe" = {

      options = {
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecStartupProbe" = {

      options = {
        "failureThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocator" = {

      options = {
        "affinity" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinity"
            )
          );
        };
        "allocationStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "collectorNotReadyGracePeriod" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "collectorTargetReloadInterval" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "enabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "env" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnv"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "filterStrategy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeSelector" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "observability" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorObservability"
            )
          );
        };
        "podDisruptionBudget" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodDisruptionBudget"
            )
          );
        };
        "podSecurityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContext"
            )
          );
        };
        "prometheusCR" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCR"
            )
          );
        };
        "replicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorResources"
            )
          );
        };
        "securityContext" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContext"
            )
          );
        };
        "serviceAccount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerations" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTolerations"
              )
            )
          );
        };
        "topologySpreadConstraints" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraints"
              )
            )
          );
        };
      };

      config = {
        "affinity" = mkOverride 1002 null;
        "allocationStrategy" = mkOverride 1002 null;
        "collectorNotReadyGracePeriod" = mkOverride 1002 null;
        "collectorTargetReloadInterval" = mkOverride 1002 null;
        "enabled" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "filterStrategy" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "observability" = mkOverride 1002 null;
        "podDisruptionBudget" = mkOverride 1002 null;
        "podSecurityContext" = mkOverride 1002 null;
        "prometheusCR" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinity"
            )
          );
        };
        "podAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinity"
            )
          );
        };
        "podAntiAffinity" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinity"
            )
          );
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "";
            type = (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "";
            type = (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "";
            type = types.int;
          };
        };

        config = { };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "";
            type = (
              types.nullOr (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnv" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorObservability" = {

      options = {
        "metrics" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorObservabilityMetrics"
            )
          );
        };
      };

      config = {
        "metrics" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorObservabilityMetrics" = {

      options = {
        "disablePrometheusAnnotations" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "enableMetrics" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "extraLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "disablePrometheusAnnotations" = mkOverride 1002 null;
        "enableMetrics" = mkOverride 1002 null;
        "extraLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodDisruptionBudget" = {

      options = {
        "maxUnavailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "minAvailable" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxUnavailable" = mkOverride 1002 null;
        "minAvailable" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextAppArmorProfile"
            )
          );
        };
        "fsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "fsGroupChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxChangePolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSeccompProfile"
            )
          );
        };
        "supplementalGroups" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.int));
        };
        "supplementalGroupsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sysctls" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "appArmorProfile" = mkOverride 1002 null;
        "fsGroup" = mkOverride 1002 null;
        "fsGroupChangePolicy" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxChangePolicy" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
        "supplementalGroupsPolicy" = mkOverride 1002 null;
        "sysctls" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextAppArmorProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSeLinuxOptions" =
      {

        options = {
          "level" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "role" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "user" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "level" = mkOverride 1002 null;
          "role" = mkOverride 1002 null;
          "type" = mkOverride 1002 null;
          "user" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSeccompProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextSysctls" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPodSecurityContextWindowsOptions" =
      {

        options = {
          "gmsaCredentialSpec" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "gmsaCredentialSpecName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "hostProcess" = mkOption {
            description = "";
            type = (types.nullOr types.bool);
          };
          "runAsUserName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "gmsaCredentialSpec" = mkOverride 1002 null;
          "gmsaCredentialSpecName" = mkOverride 1002 null;
          "hostProcess" = mkOverride 1002 null;
          "runAsUserName" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCR" = {

      options = {
        "allowNamespaces" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "denyNamespaces" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "enabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "evaluationInterval" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "podMonitorNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorNamespaceSelector"
            )
          );
        };
        "podMonitorSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorSelector"
            )
          );
        };
        "probeNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeNamespaceSelector"
            )
          );
        };
        "probeSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeSelector"
            )
          );
        };
        "scrapeClasses" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.attrs));
        };
        "scrapeConfigNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigNamespaceSelector"
            )
          );
        };
        "scrapeConfigSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigSelector"
            )
          );
        };
        "scrapeInterval" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "scrapeProtocols" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "serviceMonitorNamespaceSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorNamespaceSelector"
            )
          );
        };
        "serviceMonitorSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorSelector"
            )
          );
        };
      };

      config = {
        "allowNamespaces" = mkOverride 1002 null;
        "denyNamespaces" = mkOverride 1002 null;
        "enabled" = mkOverride 1002 null;
        "evaluationInterval" = mkOverride 1002 null;
        "podMonitorNamespaceSelector" = mkOverride 1002 null;
        "podMonitorSelector" = mkOverride 1002 null;
        "probeNamespaceSelector" = mkOverride 1002 null;
        "probeSelector" = mkOverride 1002 null;
        "scrapeClasses" = mkOverride 1002 null;
        "scrapeConfigNamespaceSelector" = mkOverride 1002 null;
        "scrapeConfigSelector" = mkOverride 1002 null;
        "scrapeInterval" = mkOverride 1002 null;
        "scrapeProtocols" = mkOverride 1002 null;
        "serviceMonitorNamespaceSelector" = mkOverride 1002 null;
        "serviceMonitorSelector" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRPodMonitorSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRProbeSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRScrapeConfigSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorPrometheusCRServiceMonitorSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorResources" = {

      options = {
        "claims" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorResourcesClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "request" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextCapabilities"
            )
          );
        };
        "privileged" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextWindowsOptions"
            )
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextAppArmorProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextSeLinuxOptions" =
      {

        options = {
          "level" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "role" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "user" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "level" = mkOverride 1002 null;
          "role" = mkOverride 1002 null;
          "type" = mkOverride 1002 null;
          "user" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextSeccompProfile" =
      {

        options = {
          "localhostProfile" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "type" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "localhostProfile" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorSecurityContextWindowsOptions" =
      {

        options = {
          "gmsaCredentialSpec" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "gmsaCredentialSpecName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "hostProcess" = mkOption {
            description = "";
            type = (types.nullOr types.bool);
          };
          "runAsUserName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "gmsaCredentialSpec" = mkOverride 1002 null;
          "gmsaCredentialSpecName" = mkOverride 1002 null;
          "hostProcess" = mkOverride 1002 null;
          "runAsUserName" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTolerations" = {

      options = {
        "effect" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraintsLabelSelector"
            )
          );
        };
        "matchLabelKeys" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "maxSkew" = mkOption {
          description = "";
          type = types.int;
        };
        "minDomains" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "nodeAffinityPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeTaintsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "topologyKey" = mkOption {
          description = "";
          type = types.str;
        };
        "whenUnsatisfiable" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "matchLabelKeys" = mkOverride 1002 null;
        "minDomains" = mkOverride 1002 null;
        "nodeAffinityPolicy" = mkOverride 1002 null;
        "nodeTaintsPolicy" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraintsLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraintsLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTargetAllocatorTopologySpreadConstraintsLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTolerations" = {

      options = {
        "effect" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraintsLabelSelector"
            )
          );
        };
        "matchLabelKeys" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "maxSkew" = mkOption {
          description = "";
          type = types.int;
        };
        "minDomains" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "nodeAffinityPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodeTaintsPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "topologyKey" = mkOption {
          description = "";
          type = types.str;
        };
        "whenUnsatisfiable" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "matchLabelKeys" = mkOverride 1002 null;
        "minDomains" = mkOverride 1002 null;
        "nodeAffinityPolicy" = mkOverride 1002 null;
        "nodeTaintsPolicy" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraintsLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraintsLabelSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecTopologySpreadConstraintsLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplates" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpec"
            )
          );
        };
        "status" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatus"
            )
          );
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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = types.str;
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatus" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "allocatedResourceStatuses" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "allocatedResources" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "capacity" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "conditions" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatusConditions"
              )
            )
          );
        };
        "currentVolumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "modifyVolumeStatus" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatusModifyVolumeStatus"
            )
          );
        };
        "phase" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "allocatedResourceStatuses" = mkOverride 1002 null;
        "allocatedResources" = mkOverride 1002 null;
        "capacity" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "currentVolumeAttributesClassName" = mkOverride 1002 null;
        "modifyVolumeStatus" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatusConditions" = {

      options = {
        "lastProbeTime" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lastTransitionTime" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "";
          type = types.str;
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "lastProbeTime" = mkOverride 1002 null;
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeClaimTemplatesStatusModifyVolumeStatus" =
      {

        options = {
          "status" = mkOption {
            description = "";
            type = types.str;
          };
          "targetVolumeAttributesClassName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "targetVolumeAttributesClassName" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumes" = {

      options = {
        "awsElasticBlockStore" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAwsElasticBlockStore"
            )
          );
        };
        "azureDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAzureDisk")
          );
        };
        "azureFile" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAzureFile")
          );
        };
        "cephfs" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCephfs")
          );
        };
        "cinder" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCinder")
          );
        };
        "configMap" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesConfigMap")
          );
        };
        "csi" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCsi"));
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPI")
          );
        };
        "emptyDir" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEmptyDir")
          );
        };
        "ephemeral" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeral")
          );
        };
        "fc" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFc"));
        };
        "flexVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlexVolume")
          );
        };
        "flocker" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlocker")
          );
        };
        "gcePersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGcePersistentDisk"
            )
          );
        };
        "gitRepo" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGitRepo")
          );
        };
        "glusterfs" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGlusterfs")
          );
        };
        "hostPath" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesHostPath")
          );
        };
        "image" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesImage")
          );
        };
        "iscsi" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesIscsi")
          );
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "nfs" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesNfs"));
        };
        "persistentVolumeClaim" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPersistentVolumeClaim"
            )
          );
        };
        "photonPersistentDisk" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPhotonPersistentDisk"
            )
          );
        };
        "portworxVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPortworxVolume"
            )
          );
        };
        "projected" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjected")
          );
        };
        "quobyte" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesQuobyte")
          );
        };
        "rbd" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesRbd"));
        };
        "scaleIO" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesScaleIO")
          );
        };
        "secret" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesSecret")
          );
        };
        "storageos" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesStorageos")
          );
        };
        "vsphereVolume" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesVsphereVolume")
          );
        };
      };

      config = {
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "csi" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "emptyDir" = mkOverride 1002 null;
        "ephemeral" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "gitRepo" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeClaim" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "projected" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAwsElasticBlockStore" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAzureDisk" = {

      options = {
        "cachingMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "diskName" = mkOption {
          description = "";
          type = types.str;
        };
        "diskURI" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "cachingMode" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesAzureFile" = {

      options = {
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = types.str;
        };
        "shareName" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCephfs" = {

      options = {
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "path" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretFile" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCephfsSecretRef"
            )
          );
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretFile" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCephfsSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCinder" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCinderSecretRef"
            )
          );
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCinderSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesConfigMap" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesConfigMapItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCsi" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "nodePublishSecretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCsiNodePublishSecretRef"
            )
          );
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeAttributes" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "nodePublishSecretRef" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "volumeAttributes" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesCsiNodePublishSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPI" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesDownwardAPIItemsResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEmptyDir" = {

      options = {
        "medium" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "sizeLimit" = mkOption {
          description = "";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "medium" = mkOverride 1002 null;
        "sizeLimit" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeral" = {

      options = {
        "volumeClaimTemplate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplate"
            )
          );
        };
      };

      config = {
        "volumeClaimTemplate" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "";
          type = (
            submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "finalizers" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource" =
      {

        options = {
          "apiGroup" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "kind" = mkOption {
            description = "";
            type = types.str;
          };
          "name" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "apiGroup" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef" =
      {

        options = {
          "apiGroup" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "kind" = mkOption {
            description = "";
            type = types.str;
          };
          "name" = mkOption {
            description = "";
            type = types.str;
          };
          "namespace" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
        };

        config = {
          "apiGroup" = mkOverride 1002 null;
          "namespace" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecResources" =
      {

        options = {
          "limits" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
          };
          "requests" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
          };
        };

        config = {
          "limits" = mkOverride 1002 null;
          "requests" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFc" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "targetWWNs" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "wwids" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "lun" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "targetWWNs" = mkOverride 1002 null;
        "wwids" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlexVolume" = {

      options = {
        "driver" = mkOption {
          description = "";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlexVolumeSecretRef"
            )
          );
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlexVolumeSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesFlocker" = {

      options = {
        "datasetName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "datasetUUID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "datasetName" = mkOverride 1002 null;
        "datasetUUID" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGcePersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "pdName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGitRepo" = {

      options = {
        "directory" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "repository" = mkOption {
          description = "";
          type = types.str;
        };
        "revision" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "directory" = mkOverride 1002 null;
        "revision" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesGlusterfs" = {

      options = {
        "endpoints" = mkOption {
          description = "";
          type = types.str;
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesHostPath" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "type" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesImage" = {

      options = {
        "pullPolicy" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "reference" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pullPolicy" = mkOverride 1002 null;
        "reference" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesIscsi" = {

      options = {
        "chapAuthDiscovery" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "chapAuthSession" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "initiatorName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "iqn" = mkOption {
          description = "";
          type = types.str;
        };
        "iscsiInterface" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "";
          type = types.int;
        };
        "portals" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesIscsiSecretRef"
            )
          );
        };
        "targetPortal" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "chapAuthDiscovery" = mkOverride 1002 null;
        "chapAuthSession" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "initiatorName" = mkOverride 1002 null;
        "iscsiInterface" = mkOverride 1002 null;
        "portals" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesIscsiSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesNfs" = {

      options = {
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "server" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPersistentVolumeClaim" = {

      options = {
        "claimName" = mkOption {
          description = "";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPhotonPersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "pdID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesPortworxVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjected" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSources"
              )
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "sources" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSources" = {

      options = {
        "clusterTrustBundle" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundle"
            )
          );
        };
        "configMap" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesConfigMap"
            )
          );
        };
        "downwardAPI" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPI"
            )
          );
        };
        "podCertificate" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesPodCertificate"
            )
          );
        };
        "secret" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesSecret"
            )
          );
        };
        "serviceAccountToken" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesServiceAccountToken"
            )
          );
        };
      };

      config = {
        "clusterTrustBundle" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "podCertificate" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "serviceAccountToken" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundle" = {

      options = {
        "labelSelector" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector"
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "signerName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "signerName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "";
            type = types.str;
          };
          "operator" = mkOption {
            description = "";
            type = types.str;
          };
          "values" = mkOption {
            description = "";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesConfigMap" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesConfigMapItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPI" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "items" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef" =
      {

        options = {
          "apiVersion" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "fieldPath" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "apiVersion" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef" =
      {

        options = {
          "containerName" = mkOption {
            description = "";
            type = (types.nullOr types.str);
          };
          "divisor" = mkOption {
            description = "";
            type = (types.nullOr (types.either types.int types.str));
          };
          "resource" = mkOption {
            description = "";
            type = types.str;
          };
        };

        config = {
          "containerName" = mkOverride 1002 null;
          "divisor" = mkOverride 1002 null;
        };

      };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesPodCertificate" = {

      options = {
        "certificateChainPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "credentialBundlePath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyPath" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "keyType" = mkOption {
          description = "";
          type = types.str;
        };
        "maxExpirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "signerName" = mkOption {
          description = "";
          type = types.str;
        };
        "userAnnotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "certificateChainPath" = mkOverride 1002 null;
        "credentialBundlePath" = mkOverride 1002 null;
        "keyPath" = mkOverride 1002 null;
        "maxExpirationSeconds" = mkOverride 1002 null;
        "userAnnotations" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesSecret" = {

      options = {
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesSecretItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesProjectedSourcesServiceAccountToken" = {

      options = {
        "audience" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "expirationSeconds" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "audience" = mkOverride 1002 null;
        "expirationSeconds" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesQuobyte" = {

      options = {
        "group" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "registry" = mkOption {
          description = "";
          type = types.str;
        };
        "tenant" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volume" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "tenant" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesRbd" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "";
          type = types.str;
        };
        "keyring" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "monitors" = mkOption {
          description = "";
          type = (types.listOf types.str);
        };
        "pool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesRbdSecretRef")
          );
        };
        "user" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "keyring" = mkOverride 1002 null;
        "pool" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesRbdSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesScaleIO" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "gateway" = mkOption {
          description = "";
          type = types.str;
        };
        "protectionDomain" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesScaleIOSecretRef");
        };
        "sslEnabled" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "storageMode" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePool" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "system" = mkOption {
          description = "";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "protectionDomain" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "sslEnabled" = mkOverride 1002 null;
        "storageMode" = mkOverride 1002 null;
        "storagePool" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesScaleIOSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesSecret" = {

      options = {
        "defaultMode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesSecretItems")
            )
          );
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "";
          type = types.str;
        };
        "mode" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesStorageos" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesStorageosSecretRef"
            )
          );
        };
        "volumeName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesStorageosSecretRef" = {

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
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorSpecVolumesVsphereVolume" = {

      options = {
        "fsType" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyID" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "storagePolicyName" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "volumePath" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "storagePolicyID" = mkOverride 1002 null;
        "storagePolicyName" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorStatus" = {

      options = {
        "image" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "scale" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "opentelemetry.io.v1beta1.OpenTelemetryCollectorStatusScale"));
        };
        "version" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "image" = mkOverride 1002 null;
        "scale" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "opentelemetry.io.v1beta1.OpenTelemetryCollectorStatusScale" = {

      options = {
        "replicas" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "statusReplicas" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "replicas" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "statusReplicas" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "opentelemetry.io"."v1alpha1"."Instrumentation" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.Instrumentation" "instrumentations"
              "Instrumentation"
              "opentelemetry.io"
              "v1alpha1"
          )
        );
        default = { };
      };
      "opentelemetry.io"."v1alpha1"."OpAMPBridge" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.OpAMPBridge" "opampbridges" "OpAMPBridge"
              "opentelemetry.io"
              "v1alpha1"
          )
        );
        default = { };
      };
      "opentelemetry.io"."v1alpha1"."TargetAllocator" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.TargetAllocator" "targetallocators"
              "TargetAllocator"
              "opentelemetry.io"
              "v1alpha1"
          )
        );
        default = { };
      };
      "opentelemetry.io"."v1beta1"."OpenTelemetryCollector" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1beta1.OpenTelemetryCollector" "opentelemetrycollectors"
              "OpenTelemetryCollector"
              "opentelemetry.io"
              "v1beta1"
          )
        );
        default = { };
      };

    }
    // {
      "instrumentations" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.Instrumentation" "instrumentations"
              "Instrumentation"
              "opentelemetry.io"
              "v1alpha1"
          )
        );
        default = { };
      };
      "opAMPBridges" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.OpAMPBridge" "opampbridges" "OpAMPBridge"
              "opentelemetry.io"
              "v1alpha1"
          )
        );
        default = { };
      };
      "openTelemetryCollectors" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1beta1.OpenTelemetryCollector" "opentelemetrycollectors"
              "OpenTelemetryCollector"
              "opentelemetry.io"
              "v1beta1"
          )
        );
        default = { };
      };
      "targetAllocators" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "opentelemetry.io.v1alpha1.TargetAllocator" "targetallocators"
              "TargetAllocator"
              "opentelemetry.io"
              "v1alpha1"
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
        name = "instrumentations";
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "Instrumentation";
        attrName = "instrumentations";
      }
      {
        name = "opampbridges";
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "OpAMPBridge";
        attrName = "opAMPBridges";
      }
      {
        name = "targetallocators";
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "TargetAllocator";
        attrName = "targetAllocators";
      }
      {
        name = "opentelemetrycollectors";
        group = "opentelemetry.io";
        version = "v1beta1";
        kind = "OpenTelemetryCollector";
        attrName = "openTelemetryCollectors";
      }
    ];

    resources = {
      "opentelemetry.io"."v1alpha1"."Instrumentation" =
        mkAliasDefinitions
          options.resources."instrumentations";
      "opentelemetry.io"."v1alpha1"."OpAMPBridge" = mkAliasDefinitions options.resources."opAMPBridges";
      "opentelemetry.io"."v1beta1"."OpenTelemetryCollector" =
        mkAliasDefinitions
          options.resources."openTelemetryCollectors";
      "opentelemetry.io"."v1alpha1"."TargetAllocator" =
        mkAliasDefinitions
          options.resources."targetAllocators";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "Instrumentation";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "OpAMPBridge";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "opentelemetry.io";
        version = "v1alpha1";
        kind = "TargetAllocator";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "opentelemetry.io";
        version = "v1beta1";
        kind = "OpenTelemetryCollector";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
