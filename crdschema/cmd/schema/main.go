package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path"
	"strings"

	"github.com/alecthomas/kong"
	"golang.org/x/sync/errgroup"
	"gopkg.in/yaml.v3"
)

type CLI struct {
	OutputDir string   `short:"o" required:"" help:"Output directory to save JSON Schemas to"`
	Manifests []string `short:"m" required:"" help:"List of manifests to get JSON Schemas from"`
}

func main() {
	var cli CLI
	kCtx := kong.Parse(&cli)

	err := kCtx.Run()

	kCtx.FatalIfErrorf(err)
}

func (c *CLI) Run() error {

	if mkdirErr := os.Mkdir(c.OutputDir, 0755); mkdirErr != nil {
		if !errors.Is(mkdirErr, os.ErrExist) {
			return mkdirErr
		}
	}

	g, errCtx := errgroup.WithContext(context.Background())

	for _, input := range c.Manifests {
		input := input
		g.Go(func() error {
			return handleFile(errCtx, input, c.OutputDir)
		})
	}

	return g.Wait()
}

func handleFile(ctx context.Context, file, ouput string) error {
	f, fileErr := os.OpenFile(file, os.O_RDONLY, 0555)
	if fileErr != nil {
		return fileErr
	}
	defer f.Close()

	decoder := yaml.NewDecoder(f)

	errs := make([]error, 0)

	for {
		var yamlDoc map[string]interface{}
		decodeErr := decoder.Decode(&yamlDoc)
		if decodeErr != nil {
			if !errors.Is(decodeErr, io.EOF) {
				return decodeErr
			} else {
				break
			}
		}

		if yamlDoc == nil {
			continue
		}

		if err := convertDoc(ctx, yamlDoc, ouput); err != nil {
			errs = append(errs, err)
		}
	}

	return errors.Join(errs...)
}

func convertDoc(ctx context.Context, doc map[string]interface{}, out string) error {
	apiVersion, apiOk := doc["apiVersion"].(string)
	if !apiOk {
		return nil
	}

	kind, kindOk := doc["kind"].(string)
	if !kindOk {
		return nil
	}

	if apiVersion != "apiextensions.k8s.io/v1" || kind != "CustomResourceDefinition" {
		return nil
	}

	spec := doc["spec"].(map[string]interface{})

	group := spec["group"].(string)
	name := spec["names"].(map[string]interface{})["kind"].(string)

	prefix := strings.Split(group, ".")[0]

	versions := spec["versions"].([]interface{})

	errs := make([]error, 0)

	for _, version := range versions {
		version := version.(map[string]interface{})
		schemaName := strings.ToLower(fmt.Sprintf("%s-%s-%s.json", name, prefix, version["name"].(string)))
		f, err := os.OpenFile(path.Join(out, schemaName), os.O_WRONLY|os.O_CREATE, 0655)
		if err != nil {
			errs = append(errs, err)
			continue
		}
		defer f.Close()

		encoder := json.NewEncoder(f)
		jsonErr := encoder.Encode(version["schema"].(map[string]interface{})["openAPIV3Schema"])
		if jsonErr != nil {
			errs = append(errs, jsonErr)
			continue
		}
	}

	return errors.Join(errs...)
}
