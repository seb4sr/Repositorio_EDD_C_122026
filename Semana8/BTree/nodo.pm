package btree::nodo;

use strict;
use warnings;

sub new {
    my ($class, $leaf) = @_;
    my $self = {
        keys     => [],
        children => [],
        leaf     => defined($leaf) ? $leaf : 1,
    };
    bless $self, $class;
    return $self;
}

sub get_keys {
    return $_[0]->{keys};
}

sub set_keys {
    my ($self, $keys_ref) = @_;
    $self->{keys} = $keys_ref;
}

sub get_children {
    return $_[0]->{children};
}

sub set_children {
    my ($self, $children_ref) = @_;
    $self->{children} = $children_ref;
}

sub is_leaf {
    return $_[0]->{leaf} ? 1 : 0;
}

sub set_leaf {
    my ($self, $leaf) = @_;
    $self->{leaf} = $leaf ? 1 : 0;
}

sub key_count {
    my ($self) = @_;
    return scalar(@{$self->{keys}});
}

sub child_count {
    my ($self) = @_;
    return scalar(@{$self->{children}});
}

sub insert_key_at {
    my ($self, $index, $key) = @_;
    splice(@{$self->{keys}}, $index, 0, $key);
}

sub remove_key_at {
    my ($self, $index) = @_;
    return splice(@{$self->{keys}}, $index, 1);
}

sub insert_child_at {
    my ($self, $index, $child) = @_;
    splice(@{$self->{children}}, $index, 0, $child);
}

sub remove_child_at {
    my ($self, $index) = @_;
    return splice(@{$self->{children}}, $index, 1);
}

sub to_string {
    my ($self) = @_;
    my $tipo = $self->is_leaf() ? "Hoja" : "Interno";
    my $keys = join(", ", @{$self->{keys}});
    return "NodoB[tipo=$tipo, keys=[$keys]]\n";
}

1;
