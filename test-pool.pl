 #!/usr/bin/perl
 {
 package MyWebServer;
 
 use HTTP::Server::Simple::CGI;
 use base qw(HTTP::Server::Simple::CGI);
 
 use File::Slurp;

 my @data = split (/\<script/, scalar( read_file ("comserver.html")));

 sub handle_request {
     my $self = shift;
     my $cgi  = shift;
     # print "HTTP/1.1 200 OK\r\n";   
     resp_hello($cgi);
 }

 sub print_chunk{
	my $data = shift;

	print sprintf('%x',length($data))."\r\n".$data."\r\n";
	
 }
 
 sub resp_hello {
     my ($cgi) = @_;   # CGI.pm object
     return if !ref $cgi;
     
     
     my $who = $cgi->param('name');
     
     
     print $cgi->header(
         -nph => 1,
	-type => 'text/html', 
	-charset => 'windows-1251', 
	-pragma => 'no-cache', 
	-Cache_control => 'no-cache',
	-Transfer_Encoding =>  'chunked',
	-Connection => 'keep-alive',
 	-Vary => 'Accept-Encoding'
	);
    
     for my $line (@data){
		$line = '<script'. $line if $line =~ /^ /;
		print_chunk($line);	
		binmode STDOUT;
		warn $line;
		sleep(1);
	}
#           $cgi->start_html("Hello"),
#           $cgi->h1("Hello $who!"),
#           $cgi->end_html;
 }
 
 } 
 
 # start the server on port 8080
 my $server = MyWebServer->new(8080);
 $server->setup('protocol' => "HTTP/1.1");
 $server->run();
 # $server->background();
 #print "Use 'kill $pid' to stop server.\n";