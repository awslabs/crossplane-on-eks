package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	"github.com/knadh/koanf"
	"github.com/knadh/koanf/providers/env"
	"github.com/pkg/errors"
)

type config struct {
	SourceQueue       string `koanf:"sourceQueue"`
	SourceBucket      string `koanf:"sourceBucket"`
	DestinationBucket string `koanf:"destinationBucket"`
	DestinationQueue  string `koanf:"destinationQueue"`
	Processor         bool   `koanf:"processor"`
	Region            string `koanf:"region"`
}

func HandleRequest(ctx context.Context, event events.SQSEvent) (string, error) {
	fmt.Printf("Handling %d messages\n ", len(event.Records))

	if conf.Processor {
		for i := range event.Records {
			name := event.Records[i].MessageId
			err := process(ctx, name, event.Records[i].Body)
			if err != nil {
				return "", err
			}
			// err = sendMessage(ctx, name)
			// if err != nil {
			// 	return "", err
			// }
		}
	} else {
		for i := range event.Records {
			attributes := event.Records[i].MessageAttributes
			if attri, ok := attributes["s3Key"]; !ok {
				return "", fmt.Errorf("s3Key not found in attributes")
			} else {
				err := printContent(ctx, *attri.StringValue)
				if err != nil {
					return "", errors.Wrap(printContent(ctx, *attri.StringValue), "could not print")
				}
			}
		}
	}

	return fmt.Sprintf("Handled %d messages", len(event.Records)), nil
}

var conf *config
var sqsClient *sqs.Client
var s3Client *s3.Client

func main() {
	if conf == nil {
		err := newConfig()
		if err != nil {
			panic(err)
		}
	}
	if sqsClient == nil || s3Client == nil {
		err := newAWSConfig()
		if err != nil {
			panic(err)
		}
	}
	fmt.Printf("%+v\n", *conf)
	lambda.Start(HandleRequest)
}

func newAWSConfig() error {
	cnf, err := awsconfig.LoadDefaultConfig(context.Background(), awsconfig.WithRegion(conf.Region))
	if err != nil {
		return errors.Wrap(err, "could not load default config")
	}
	sqsClient = sqs.NewFromConfig(cnf)
	s3Client = s3.NewFromConfig(cnf)
	return nil
}

func newConfig() error {
	konf := koanf.New(".")

	envProvider := env.Provider("APP__CONFIG__", ".", func(s string) string {
		return strings.Replace(
			strings.ToLower(strings.TrimPrefix(s, "APP__CONFIG__")), "_", ".", -1)
	})
	awsEnvProvider := env.Provider("AWS_", ".", func(s string) string {
		return strings.Replace(
			strings.ToLower(strings.TrimPrefix(s, "AWS_")), "_", ".", -1)
	})
	err := konf.Load(envProvider, nil)
	if err != nil {
		return errors.Wrap(err, "could not load app environment variables")
	}
	err = konf.Load(awsEnvProvider, nil)
	if err != nil {
		return errors.Wrap(err, "could not load aws environment variables")
	}
	var cnf config
	err = konf.Unmarshal("", &cnf)
	if err != nil {
		return errors.Wrap(err, "unable to marshal configuration")
	}
	conf = &cnf
	return nil
}

func process(ctx context.Context, name string, body string) error {
	fmt.Printf("processing %s\n", name)
	input := s3.PutObjectInput{
		Bucket: &conf.DestinationBucket,
		Body:   strings.NewReader(body),
		Key:    aws.String(fmt.Sprintf("processed/%s", name)),
	}
	_, err := s3Client.PutObject(ctx, &input)
	return errors.Wrap(err, "could not put object")
}

func sendMessage(ctx context.Context, location string) error {
	input := sqs.SendMessageInput{
		MessageBody:  aws.String("notUsed"),
		QueueUrl:     &conf.DestinationQueue,
		DelaySeconds: 1,
		MessageAttributes: map[string]types.MessageAttributeValue{
			"s3Key": {
				DataType:    aws.String("String"),
				StringValue: &location,
			},
		},
	}
	_, err := sqsClient.SendMessage(ctx, &input)
	return errors.Wrap(err, "could not send message")
}

func printContent(ctx context.Context, name string) error {
	input := s3.GetObjectInput{
		Bucket: &conf.DestinationBucket,
		Key:    aws.String(fmt.Sprintf("processed/%s", name)),
	}
	resp, err := s3Client.GetObject(ctx, &input)
	if err != nil {
		return errors.Wrap(err, "could not retrieve object")
	}
	content, err := io.ReadAll(resp.Body)
	if err != nil {
		return errors.Wrap(err, "could not read from s3 object")
	}
	fmt.Printf("Processed content %s \n", string(content))
	return nil
}

func getObjectName(body string) (string, error) {
	var m events.SNSEntity
	fmt.Println(body)
	err := json.Unmarshal([]byte(body), &m)
	if err != nil {
		return "", fmt.Errorf("could not unmarshal body")
	}
	fmt.Println(m)
	val, ok := m.MessageAttributes["s3Key"]
	if !ok {
		return "", fmt.Errorf("s3Key not found in map")
	}
	type kv struct {
		Type  string
		Value string
	}
	k := val.(kv)
	return k.Value, nil
}
