"""Bootstrap generator for the SCP-local wrappers.

HISTORICAL/BOOTSTRAP: this wrote the first 12 generic wrappers. The final tree
also contains hand-written `cell-clustering/code/clustering.R`,
`reference-mapping/code/transfer.R`, and the `run_seurat_integration` branch in
`batch-integration/code/analysis.R`. Do not rerun over existing final assets;
main() refuses unless --force is passed, and even then review the diff.
"""
from pathlib import Path
import hashlib
import json
import sys

ROOT = Path('E:/research-wiki/知识库/methods')
OUT = Path('E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki')
BUNDLE = ROOT/'scp-local-source/code/SCP-local'
SPEC = {
 'cell-quality-control': ('RunCellQC', 'SCP-cellqc.R', ['Seurat'], 'srt'),
 'doublet-detection': ('RunDoubletCalling', 'SCP-cellqc.R', ['Seurat','scDblFinder'], 'srt'),
 'batch-integration': ('Harmony_integrate', 'SCP-workflow.R', ['Seurat','harmony'], 'srtMerge'),
 'differential-expression': ('RunDEtest', 'SCP-analysis.R', ['Seurat','BiocParallel'], 'srt'),
 'gene-set-enrichment': ('RunEnrichment', 'SCP-analysis.R', ['Seurat','clusterProfiler','BiocParallel'], 'geneID'),
 'gene-set-scoring': ('CellScoring', 'SCP-analysis.R', ['Seurat','BiocParallel'], 'srt'),
 'trajectory-inference': ('RunSlingshot', 'SCP-analysis.R', ['Seurat','slingshot'], 'srt'),
 'rna-velocity': ('RunSCVELO', 'SCP-analysis.R', ['Seurat','reticulate'], 'srt'),
 'cell-type-annotation': ('RunSingleR', 'SCP-cell_annotation.R', ['Seurat','SingleR'], 'reference'),
 'reference-mapping': ('RunSeuratMap', 'SCP-projection.R', ['Seurat'], 'reference'),
 'dimensionality-reduction': ('RunDimReduction', 'SCP-workflow.R', ['Seurat'], 'srt'),
 'dynamic-feature-analysis': ('RunDynamicFeatures', 'SCP-analysis.R', ['Seurat','mgcv','BiocParallel'], 'srt'),
}

HELPER = '''# Wrapper adapter, GPL-3, derived from the preserved SCP-local v0.5.6.
# Copy this code directory AND the complete SCP-local dependency bundle into
# the project. bundle is always supplied by caller; no wiki path is inferred.
# Loader side effects: attaches installed DESCRIPTION Imports/Depends; loads
# palettes; may initialize namespaces. future.globals.maxSize and root options
# restored by this adapter. Upstream algorithm can change RNG state.
# Only automatic installation helpers are replaced by fail-only guards in the
# transient engine. Statistical algorithms/defaults are not changed.

load_scp_engine <- function(bundle) {
  bundle <- normalizePath(bundle, mustWork=TRUE)
  expected <- BUNDLE_HASHES
  paths <- file.path(bundle, names(expected))
  if (any(!file.exists(paths)) || !identical(unname(tools::md5sum(paths)), unname(expected)))
    stop('SCP-local dependency bundle differs from pinned source; revalidate before use')
  old <- options(SCP.local.root=bundle)
  old_future <- getOption('future.globals.maxSize')
  on.exit({options(old); options(future.globals.maxSize=old_future)}, add=TRUE)
  loader <- new.env(parent=globalenv())
  sys.source(file.path(bundle, 'load_scp_local.R'), envir=loader)
  engine <- loader$SCP_local
  engine$check_R <- function(packages, ...) {
    for (spec in packages) {
      parts <- strsplit(spec, '@|==')[[1]]
      pkg <- sub('^.*/', '', parts[1])
      if (!requireNamespace(pkg, quietly=TRUE))
        stop('Missing R dependency: ', pkg, '; automatic installation is disabled')
      if (length(parts)>1 && utils::packageVersion(pkg) < package_version(parts[2]))
        stop('R dependency too old: ', pkg, '; requires >= ', parts[2])
    }
    invisible(NULL)
  }
  engine$check_Python <- function(packages, ...) {
    if (!nzchar(Sys.getenv('RETICULATE_PYTHON')))
      stop('Set RETICULATE_PYTHON to an existing project interpreter; installation disabled')
    for (pkg in packages) {
      module <- sub('[-].*', '', sub('==.*', '', pkg))
      if (!reticulate::py_module_available(module))
        stop('Missing Python dependency: ', pkg, '; automatic installation is disabled')
    }
    invisible(NULL)
  }
  engine$PrepareEnv <- function(...) stop('Automatic environment creation disabled')
  engine
}

.scp_run <- function(engine, name, arguments) {
  if (!is.list(arguments) || any(!nzchar(names(arguments))) || anyDuplicated(names(arguments)))
    stop('Arguments must be a uniquely named list')
  warnings <- character()
  result <- withCallingHandlers(do.call(engine[[name]], arguments), warning=function(w) {
    warnings <<- c(warnings, conditionMessage(w))
  })
  packages <- loadedNamespaces()
  versions <- setNames(lapply(packages, function(x) as.character(utils::packageVersion(x))), packages)
  list(result=result, diagnostics=list(upstream_function=name,
       source_version='SCP-local 0.5.6; pinned bundle', parameters=arguments[setdiff(names(arguments),
         c('srt','srtMerge','srt_query','srt_ref'))], warnings=unique(warnings),
       dependency_versions=versions, automatic_installation=FALSE,
       loader_side_effects='DESCRIPTION packages attached; namespaces loaded; root/future options restored',
       rng='upstream function may set/change global RNG state'))
}
'''

def main():
    if '--force' not in sys.argv:
        existing = sorted(ROOT.glob('*/code/analysis.R'))
        if existing:
            raise SystemExit(
                'Refusing to overwrite final assets. Review the existing wrappers and '
                'pass --force only if you have diffed the generated result.')
    pinned = sorted(p for p in BUNDLE.rglob('*') if p.is_file() and
                    (p.suffix in {'.R','.py','.rda'} or p.name=='DESCRIPTION'))
    hashes = {p.relative_to(BUNDLE).as_posix():hashlib.md5(p.read_bytes()).hexdigest() for p in pinned}
    r_hashes = 'c('+',\n'.join(json.dumps(k)+'='+json.dumps(v) for k,v in hashes.items())+')'
    inventory=[]
    for family,(function,src,deps,kind) in SPEC.items():
        folder=ROOT/family
        (folder/'code').mkdir(parents=True,exist_ok=True)
        (folder/'example').mkdir(exist_ok=True)
        (folder/'verification').mkdir(exist_ok=True)
        entry='run_'+family.replace('-','_')
        if kind=='reference':
            signature='srt_query, srt_ref, bundle, parameters=list()'
            inputs='list(srt_query=srt_query, srt_ref=srt_ref)'
        else:
            input_name='gene_ids' if kind=='geneID' else 'srt'
            signature=f'{input_name}, bundle, parameters=list()'
            inputs=f'list({kind}={input_name})'
        code=HELPER.replace('BUNDLE_HASHES',r_hashes)
        code+=f'''\n# Source mapping: SCP-local/R/{src}:{function}; no algorithm rewritten.
{entry} <- function({signature}) {{
  if (!is.list(parameters) || (length(parameters) &&
      (is.null(names(parameters)) || any(!nzchar(names(parameters))) || anyDuplicated(names(parameters)))))
    stop('parameters must be a uniquely named list')
  engine <- load_scp_engine(bundle)
  .scp_run(engine, '{function}', c({inputs}, parameters))
}}
'''
        (folder/'code/analysis.R').write_text(code,encoding='utf-8')
        implementation=dict(id='scp-'+function.lower(),title='SCP '+function,language='R',
            entrypoint='code/analysis.R:'+entry, dependencies=deps,
            verification='verification/scp-'+function.lower()+'.json')
        usage=dict(entrypoint=implementation['entrypoint'],
            required_copy=['code/analysis.R','complete SCP-local directory from methods/scp-local-source/code/'],
            bundle_argument='path to the copied SCP-local directory in the project; pinned hashes checked',
            input_contract='Existing Seurat object and explicit named source-function parameters; reference/query for mapping or annotation; gene_ids for enrichment',
            output_contract='list(result=<unchanged upstream return>, diagnostics=<function, versions, warnings, parameters>)',
            source_mapping=f'methods/scp-local-source/code/SCP-local/R/{src}:{function}',
            license='GPL-3 (SCP GPL >=3)',
            side_effects=['source attaches installed dependencies','upstream RNG may change',
                          'upstream plotting/saving remains controlled by explicit parameters',
                          'automatic package/environment installation blocked'],
            parameters='Match original upstream arguments; no automatic threshold/data/split choice. Read source and family page before use.')
        (folder/'example/usage.json').write_text(json.dumps(usage,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
        inventory.append(dict(family=family,implementations=[implementation],source_mapping=usage['source_mapping']))
    (OUT/'function-inventory.json').write_text(json.dumps(inventory,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

if __name__=='__main__': main()
