requires 'perl', '5.008001';
requires 'Cache::LRU::WithExpires', '0.03';
requires 'Plack', '1.0029';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

