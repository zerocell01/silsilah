@extends('layouts.app')

@section('content')
<h2 class="page-header">
    {{ trans('app.kepala_keluarga') }}
    <small class="pull-right">{{ trans('app.total_kepala_keluarga', ['total' => $kepalaKeluarga->count()]) }}</small>
</h2>

@foreach ($kepalaKeluarga->chunk(4) as $chunkedUsers)
<div class="row">
    @foreach ($chunkedUsers as $user)
    <div class="col-md-3">
        <div class="panel panel-default">
            <div class="panel-heading text-center">
                {{ userPhoto($user, ['style' => 'width:100%;max-width:300px']) }}
            </div>
            <div class="panel-body">
                <h3 class="panel-title">{{ $user->profileLink() }}</h3>
                <hr style="margin: 5px 0;">
                <div><strong>{{ trans('app.wife') }}:</strong>
                    @foreach ($user->wifes as $wife)
                        <div>{{ $wife->name }}</div>
                    @endforeach
                </div>
                <hr style="margin: 5px 0;">
                <div><strong>{{ trans('app.child_count') }}:</strong> {{ $user->childs->count() }}</div>
            </div>
            <div class="panel-footer">
                {{ link_to_route('users.show', trans('app.show_profile'), [$user->id], ['class' => 'btn btn-default btn-xs']) }}
                {{ link_to_route('users.chart', trans('app.show_family_chart'), [$user->id], ['class' => 'btn btn-default btn-xs']) }}
            </div>
        </div>
    </div>
    @endforeach
</div>
@endforeach

@if ($kepalaKeluarga->isEmpty())
<p>{{ trans('app.data_not_available') }}</p>
@endif
@endsection
