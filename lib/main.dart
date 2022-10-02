import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsGraphql = """
query products {
  products(first: 5, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail{
          url
        }
      }
    }
  }
}
""";

void main() {
  final HttpLink httpLink = HttpLink(
    'https://demo.saleor.io/graphql/',
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  var app = GraphQLProvider(
    child: MyApp(),
    client: client,
  );

  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graphql',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Graphql'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
          options: QueryOptions(
            document: gql(productsGraphql),
          ),
          builder: (QueryResult result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Center(
                child: Text(result.exception.toString()),
              );
            }

            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List? products = result.data?['products']?['edges'];

            if (products == null) {
              return const Text('No products');
            }

            return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    title: Text(product['node']['name'] ?? ''),
                  );
                });
          }), //const Center(),
    );
  }
}
